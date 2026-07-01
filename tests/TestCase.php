<?php
/**
 * Base test case. Boots and tears down Brain Monkey so tests can mock WordPress
 * functions without loading WordPress. Extend this for any test that touches WP.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

declare(strict_types=1);

namespace {{PLUGIN_NAMESPACE}}\Tests;

use Brain\Monkey;
use PHPUnit\Framework\TestCase as PHPUnitTestCase;

abstract class TestCase extends PHPUnitTestCase {

	protected function setUp(): void {
		parent::setUp();
		Monkey\setUp();
	}

	protected function tearDown(): void {
		Monkey\tearDown();
		parent::tearDown();
	}
}
