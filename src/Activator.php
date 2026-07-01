<?php
/**
 * Runs on plugin activation.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

declare(strict_types=1);

namespace {{PLUGIN_NAMESPACE}};

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Activation tasks: set defaults, create tables, schedule cron.
 */
final class Activator {

	/**
	 * Handle activation.
	 *
	 * @return void
	 */
	public static function activate(): void {
		if ( false === get_option( '{{PLUGIN_PREFIX}}_settings' ) ) {
			add_option( '{{PLUGIN_PREFIX}}_settings', array() );
		}
	}
}
