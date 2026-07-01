<?php
/**
 * Main plugin controller.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

declare(strict_types=1);

namespace {{PLUGIN_NAMESPACE}};

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

use {{PLUGIN_NAMESPACE}}\Admin\SettingsPage;

/**
 * Wires up the plugin's hooks. One instance per request.
 */
final class Plugin {

	/**
	 * Singleton instance.
	 *
	 * @var Plugin|null
	 */
	private static ?Plugin $instance = null;

	/**
	 * Get the shared instance.
	 *
	 * @return Plugin
	 */
	public static function instance(): Plugin {
		if ( null === self::$instance ) {
			self::$instance = new self();
		}
		return self::$instance;
	}

	/**
	 * Private constructor. Use instance().
	 */
	private function __construct() {}

	/**
	 * Register hooks.
	 *
	 * @return void
	 */
	public function run(): void {
		add_action( 'init', array( $this, 'load_textdomain' ) );

		if ( is_admin() ) {
			( new SettingsPage() )->register();
		}
	}

	/**
	 * Load translations.
	 *
	 * @return void
	 */
	public function load_textdomain(): void {
		load_plugin_textdomain(
			'{{TEXT_DOMAIN}}',
			false,
			dirname( plugin_basename( {{PLUGIN_CONSTANT}}_FILE ) ) . '/languages'
		);
	}
}
