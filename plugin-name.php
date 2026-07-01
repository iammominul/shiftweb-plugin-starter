<?php
/**
 * Plugin Name:       {{PLUGIN_NAME}}
 * Plugin URI:        {{PLUGIN_URI}}
 * Description:        {{PLUGIN_DESCRIPTION}}
 * Version:           1.0.0
 * Requires at least: 6.0
 * Requires PHP:      7.4
 * Author:            {{PLUGIN_AUTHOR}}
 * Author URI:        {{PLUGIN_AUTHOR_URI}}
 * License:           GPL v2 or later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       {{TEXT_DOMAIN}}
 * Domain Path:       /languages
 * Update URI:        false
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

declare(strict_types=1);

// No direct file access.
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

define( '{{PLUGIN_CONSTANT}}_VERSION', '1.0.0' );
define( '{{PLUGIN_CONSTANT}}_FILE', __FILE__ );
define( '{{PLUGIN_CONSTANT}}_DIR', plugin_dir_path( __FILE__ ) );
define( '{{PLUGIN_CONSTANT}}_URL', plugin_dir_url( __FILE__ ) );

// Composer autoloader. Run "composer install" after setup.
$autoloader = {{PLUGIN_CONSTANT}}_DIR . 'vendor/autoload.php';
if ( is_readable( $autoloader ) ) {
	require $autoloader;
}

register_activation_hook( __FILE__, array( '{{PLUGIN_NAMESPACE}}\Activator', 'activate' ) );
register_deactivation_hook( __FILE__, array( '{{PLUGIN_NAMESPACE}}\Deactivator', 'deactivate' ) );

/**
 * Boot the plugin once all plugins are loaded.
 */
add_action(
	'plugins_loaded',
	static function () {
		\{{PLUGIN_NAMESPACE}}\Plugin::instance()->run();
	}
);
