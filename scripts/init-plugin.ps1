#!/usr/bin/env pwsh
<#
.SYNOPSIS
	Initialize a new plugin from the ShiftWeb Plugin Starter.

.DESCRIPTION
	Replaces the {{PLACEHOLDER}} tokens across the repo and renames the main
	plugin file. Everything is derived from -Name unless you override it.

.EXAMPLE
	./scripts/init-plugin.ps1 -Name "Booking Reminders" -Description "Sends booking reminder emails."
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)] [string] $Name,
	[string] $Slug,
	[string] $Namespace,
	[string] $Description = "A custom WordPress plugin by ShiftWeb.",
	[string] $Author = "ShiftWeb",
	[string] $AuthorUri = "https://shiftweb.com",
	[string] $PluginUri = "https://shiftweb.com"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

if ( -not $Slug ) {
	$Slug = ($Name.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
}
if ( -not $Namespace ) {
	$studly = ((Get-Culture).TextInfo.ToTitleCase(($Slug -replace '-', ' '))) -replace ' ', ''
	$Namespace = "ShiftWeb\$studly"
}

$prefix        = $Slug -replace '-', '_'
$constant      = $prefix.ToUpper()
$namespaceJson = $Namespace -replace '\\', '\\'
$year          = (Get-Date).Year.ToString()

# Longer tokens first so no token is a prefix of another during replacement.
$tokens = [ordered]@{
	'{{PLUGIN_NAMESPACE_JSON}}' = $namespaceJson
	'{{PLUGIN_NAMESPACE}}'      = $Namespace
	'{{PLUGIN_DESCRIPTION}}'    = $Description
	'{{PLUGIN_AUTHOR_URI}}'     = $AuthorUri
	'{{PLUGIN_AUTHOR}}'         = $Author
	'{{PLUGIN_CONSTANT}}'       = $constant
	'{{PLUGIN_PREFIX}}'         = $prefix
	'{{PLUGIN_NAME}}'           = $Name
	'{{PLUGIN_SLUG}}'           = $Slug
	'{{TEXT_DOMAIN}}'           = $Slug
	'{{PLUGIN_URI}}'            = $PluginUri
	'{{YEAR}}'                  = $year
}

$excludeDirs = @('.git', 'vendor', 'node_modules', 'scripts')
$excludeFiles = @('README.md')
$binaryExt = @('.png', '.jpg', '.jpeg', '.gif', '.ico', '.woff', '.woff2', '.ttf', '.zip')
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

Get-ChildItem -Path $root -Recurse -File | Where-Object {
	$rel = $_.FullName.Substring($root.Length).TrimStart('\', '/')
	$top = ($rel -split '[\\/]')[0]
	( -not ($excludeDirs -contains $top) ) -and
	( -not ($excludeFiles -contains $_.Name) ) -and
	( -not ($binaryExt -contains $_.Extension.ToLower()) )
} | ForEach-Object {
	$content = [System.IO.File]::ReadAllText($_.FullName)
	foreach ( $key in $tokens.Keys ) {
		$content = $content.Replace($key, $tokens[$key])
	}
	[System.IO.File]::WriteAllText($_.FullName, $content, $utf8NoBom)
}

# Rename the main plugin file.
$main = Join-Path $root 'plugin-name.php'
if ( Test-Path $main ) {
	Rename-Item -LiteralPath $main -NewName "$Slug.php"
}

Write-Host ""
Write-Host "Initialized: $Name"
Write-Host "  Slug:      $Slug"
Write-Host "  Namespace: $Namespace"
Write-Host "  Main file: $Slug.php"
Write-Host ""
Write-Host "Next: composer install, then fill out INTAKE.md."
Write-Host "To ship a release, run ./scripts/build-zip.ps1 (outputs to /dist)."
Write-Host "You can delete README.md and scripts/init-plugin.* once you are set up."
