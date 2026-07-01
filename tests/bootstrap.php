<?php
/**
 * PHPUnit bootstrap.
 *
 * These are plain unit tests that do not load WordPress. For tests that need
 * WordPress functions, add the WP test suite or a mocking library (for example
 * Brain Monkey) and wire it up here.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

$autoloader = dirname( __DIR__ ) . '/vendor/autoload.php';

if ( ! is_readable( $autoloader ) ) {
	fwrite( STDERR, "Run \"composer install\" before running the tests.\n" );
	exit( 1 );
}

require $autoloader;
