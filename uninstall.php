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

delete_option( '{{PLUGIN_PREFIX}}_settings' );

// For multisite, clean up per-site options as well.
if ( is_multisite() ) {
	$site_ids = get_sites( array( 'fields' => 'ids' ) );
	foreach ( $site_ids as $site_id ) {
		switch_to_blog( (int) $site_id );
		delete_option( '{{PLUGIN_PREFIX}}_settings' );
		restore_current_blog();
	}
}
