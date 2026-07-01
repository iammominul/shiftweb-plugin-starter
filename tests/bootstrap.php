<?php
/**
 * PHPUnit bootstrap.
 *
 * Plain, WordPress-free unit tests. WordPress functions are mocked per test with
 * Brain Monkey via the {{PLUGIN_NAMESPACE}}\Tests\TestCase base class. For tests
 * that need real hook or database behavior, add the WordPress integration test
 * suite and wire it up here.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

declare(strict_types=1);

$autoloader = dirname( __DIR__ ) . '/vendor/autoload.php';

if ( ! is_readable( $autoloader ) ) {
	fwrite( STDERR, "Run \"composer install\" before running the tests.\n" );
	exit( 1 );
}

require $autoloader;
