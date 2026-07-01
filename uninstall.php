<?php
/**
 * Uninstall handler. Runs only when the user deletes the plugin.
 *
 * Remove the plugin's own options and data here so nothing is left behind.
 * Do not remove user content the site still needs.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

declare(strict_types=1);

if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
	exit;
}

/**
 * Remove the plugin's stored data. Wrapped in a prefixed function so the loop
 * variables stay local and never leak into the global scope.
 *
 * @return void
 */
function {{PLUGIN_PREFIX}}_uninstall(): void {
	delete_option( '{{PLUGIN_PREFIX}}_settings' );

	// For multisite, clean up per-site options as well.
	if ( is_multisite() ) {
		foreach ( get_sites( array( 'fields' => 'ids' ) ) as $blog_id ) {
			switch_to_blog( (int) $blog_id );
			delete_option( '{{PLUGIN_PREFIX}}_settings' );
			restore_current_blog();
		}
	}
}

{{PLUGIN_PREFIX}}_uninstall();
