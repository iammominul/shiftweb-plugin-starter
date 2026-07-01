#!/usr/bin/env pwsh
<#
.SYNOPSIS
	Build a production-ready plugin zip in /dist.

.DESCRIPTION
	Copies the plugin to a staging folder, installs runtime-only Composer
	dependencies (which also generates the autoloader the plugin needs for its
	own classes), strips development files, and packages the result as
	dist/<slug>-<version>.zip with the slug as the top-level folder, ready to
	upload via Plugins > Add New > Upload Plugin.

	Run "composer check" first so you never ship a failing build.

.EXAMPLE
	./scripts/build-zip.ps1
#>
[CmdletBinding()]
param(
	[string] $Slug,
	[switch] $KeepStaging
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

# Locate the main plugin file (the root .php that carries the plugin header).
if ( -not $Slug ) {
	$mainFile = Get-ChildItem -Path $root -Filter *.php -File | Where-Object {
		( Get-Content $_.FullName -TotalCount 20 ) -match 'Plugin Name:'
	} | Select-Object -First 1
	if ( -not $mainFile ) {
		throw "Could not find the main plugin file. Run the init script first, or pass -Slug."
	}
	$Slug = [System.IO.Path]::GetFileNameWithoutExtension( $mainFile.Name )
} else {
	$mainFile = Get-Item ( Join-Path $root "$Slug.php" )
}

# Read the version from the plugin header.
$version = '0.0.0'
foreach ( $line in Get-Content $mainFile.FullName -TotalCount 30 ) {
	if ( $line -match 'Version:\s*(.+)$' ) {
		$version = $Matches[1].Trim()
		break
	}
}

Write-Host "Building $Slug $version..."

# Fresh staging folder named after the slug. WordPress expects this folder as
# the single top-level entry inside the zip.
$build   = Join-Path $root 'build'
$staging = Join-Path $build $Slug
if ( Test-Path $build ) {
	Remove-Item $build -Recurse -Force
}
New-Item -ItemType Directory -Path $staging -Force | Out-Null

# Files and folders that never ship to production.
$exclude = @(
	'.git', '.github', '.claude', 'node_modules', 'vendor', 'tests', 'scripts',
	'build', 'dist', '.gitignore', '.gitattributes', '.editorconfig',
	'CLAUDE.md', 'INTAKE.md', 'README.md', 'phpcs.xml.dist',
	'phpstan.neon.dist', 'phpunit.xml.dist'
)

Get-ChildItem -Path $root -Force | Where-Object {
	$exclude -notcontains $_.Name
} | ForEach-Object {
	Copy-Item $_.FullName -Destination $staging -Recurse -Force
}

# Install runtime dependencies and build the optimized autoloader. Even with no
# third-party runtime deps this produces the vendor/autoload.php the plugin's
# own PSR-4 classes rely on.
$env:COMPOSER_ROOT_VERSION = $version
Push-Location $staging
try {
	# Composer prints progress and notices to stderr. Turn off Stop handling for
	# the native call and stringify the stream so those notices do not abort the
	# script; rely on the exit code to detect a real failure.
	$prevEAP = $ErrorActionPreference
	$ErrorActionPreference = 'Continue'
	& composer install --no-dev --optimize-autoloader --no-interaction --no-progress 2>&1 |
		ForEach-Object { "$_" }
	$code = $LASTEXITCODE
	$ErrorActionPreference = $prevEAP
	if ( $code -ne 0 ) {
		throw "composer install failed."
	}
} finally {
	Pop-Location
}

# composer files are only needed for the build, not at runtime.
Remove-Item ( Join-Path $staging 'composer.json' ) -Force -ErrorAction SilentlyContinue
Remove-Item ( Join-Path $staging 'composer.lock' ) -Force -ErrorAction SilentlyContinue

# Zip the staging parent so the archive keeps the <slug>/ folder at its root.
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Path $dist -Force | Out-Null
$zip = Join-Path $dist "$Slug-$version.zip"
if ( Test-Path $zip ) {
	Remove-Item $zip -Force
}

# Build the archive entry by entry so paths use forward slashes. The .NET
# CreateFromDirectory helper writes Windows backslashes on PowerShell, which
# breaks extraction when WordPress runs on Linux.
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipStream = [System.IO.File]::Open( $zip, [System.IO.FileMode]::Create )
$archive   = New-Object System.IO.Compression.ZipArchive( $zipStream, [System.IO.Compression.ZipArchiveMode]::Create )
try {
	Get-ChildItem -Path $build -Recurse -File | ForEach-Object {
		$entry = $_.FullName.Substring( $build.Length + 1 ) -replace '\\', '/'
		[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
			$archive, $_.FullName, $entry, [System.IO.Compression.CompressionLevel]::Optimal
		) | Out-Null
	}
} finally {
	$archive.Dispose()
	$zipStream.Dispose()
}

if ( -not $KeepStaging ) {
	Remove-Item $build -Recurse -Force
}

Write-Host ""
Write-Host "Built: dist/$Slug-$version.zip"
Write-Host "Upload it via Plugins > Add New > Upload Plugin."
