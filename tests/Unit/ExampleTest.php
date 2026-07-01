<?php
/**
 * Example unit test. Replace with real tests as you build features.
 * Write tests first for anything security-critical.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

declare(strict_types=1);

namespace {{PLUGIN_NAMESPACE}}\Tests\Unit;

use PHPUnit\Framework\TestCase;

final class ExampleTest extends TestCase {

	public function test_bootstrap_file_exists(): void {
		$this->assertFileExists( dirname( __DIR__, 2 ) . '/{{PLUGIN_SLUG}}.php' );
	}
}
