<?php
/**
 * Example unit test. Replace with real tests as you build features.
 * Write tests first for anything security-critical.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

declare(strict_types=1);

namespace {{PLUGIN_NAMESPACE}}\Tests\Unit;

use {{PLUGIN_NAMESPACE}}\Tests\TestCase;
use Brain\Monkey\Functions;

final class ExampleTest extends TestCase {

	public function test_main_plugin_file_exists(): void {
		$this->assertFileExists( dirname( __DIR__, 2 ) . '/{{PLUGIN_SLUG}}.php' );
	}

	/**
	 * Shows the Brain Monkey pattern: stub a WordPress function, then test the
	 * code that calls it. Delete this once you have real tests.
	 */
	public function test_wordpress_functions_can_be_mocked(): void {
		Functions\when( 'esc_html' )->returnArg();

		$this->assertSame( 'Hello', esc_html( 'Hello' ) );
	}
}
