<?php
/**
 * Runs on plugin deactivation.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

namespace {{PLUGIN_NAMESPACE}};

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Deactivation tasks: unschedule cron, clear transients.
 * Do not delete user data here. That belongs in uninstall.php.
 */
final class Deactivator {

	/**
	 * Handle deactivation.
	 *
	 * @return void
	 */
	public static function deactivate(): void {
		// Example: wp_clear_scheduled_hook( '{{PLUGIN_PREFIX}}_cron' ).
	}
}
