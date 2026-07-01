<?php
/**
 * Admin settings page. Serves as a reference for the security patterns every
 * admin surface in this plugin must follow: capability check, nonce, sanitize
 * on input, escape on output.
 *
 * @package {{PLUGIN_NAMESPACE}}
 */

namespace {{PLUGIN_NAMESPACE}}\Admin;

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Registers an options page under Settings.
 */
final class SettingsPage {

	private const OPTION      = '{{PLUGIN_PREFIX}}_settings';
	private const PAGE_SLUG   = '{{PLUGIN_SLUG}}';
	private const OPTION_GROUP = '{{PLUGIN_PREFIX}}_group';

	/**
	 * Hook into admin.
	 *
	 * @return void
	 */
	public function register(): void {
		add_action( 'admin_menu', array( $this, 'add_menu' ) );
		add_action( 'admin_init', array( $this, 'register_settings' ) );
	}

	/**
	 * Add the menu item.
	 *
	 * @return void
	 */
	public function add_menu(): void {
		add_options_page(
			__( '{{PLUGIN_NAME}}', '{{TEXT_DOMAIN}}' ),
			__( '{{PLUGIN_NAME}}', '{{TEXT_DOMAIN}}' ),
			'manage_options',
			self::PAGE_SLUG,
			array( $this, 'render' )
		);
	}

	/**
	 * Register the setting and its fields. The Settings API handles the nonce.
	 *
	 * @return void
	 */
	public function register_settings(): void {
		register_setting(
			self::OPTION_GROUP,
			self::OPTION,
			array(
				'type'              => 'array',
				'sanitize_callback' => array( $this, 'sanitize' ),
				'default'           => array(),
			)
		);

		add_settings_section(
			'{{PLUGIN_PREFIX}}_main',
			__( 'General', '{{TEXT_DOMAIN}}' ),
			'__return_false',
			self::PAGE_SLUG
		);

		add_settings_field(
			'example_text',
			__( 'Example setting', '{{TEXT_DOMAIN}}' ),
			array( $this, 'render_example_field' ),
			self::PAGE_SLUG,
			'{{PLUGIN_PREFIX}}_main'
		);
	}

	/**
	 * Sanitize all input before it is stored.
	 *
	 * @param mixed $input Raw submitted value.
	 * @return array
	 */
	public function sanitize( $input ): array {
		$clean = array();

		if ( isset( $input['example_text'] ) ) {
			$clean['example_text'] = sanitize_text_field( wp_unslash( $input['example_text'] ) );
		}

		return $clean;
	}

	/**
	 * Render one field. Escape on output.
	 *
	 * @return void
	 */
	public function render_example_field(): void {
		$settings = get_option( self::OPTION, array() );
		$value    = isset( $settings['example_text'] ) ? $settings['example_text'] : '';

		printf(
			'<input type="text" name="%1$s[example_text]" value="%2$s" class="regular-text" />',
			esc_attr( self::OPTION ),
			esc_attr( $value )
		);
	}

	/**
	 * Render the page.
	 *
	 * @return void
	 */
	public function render(): void {
		if ( ! current_user_can( 'manage_options' ) ) {
			return;
		}
		?>
		<div class="wrap">
			<h1><?php echo esc_html( get_admin_page_title() ); ?></h1>
			<form action="options.php" method="post">
				<?php
				settings_fields( self::OPTION_GROUP );
				do_settings_sections( self::PAGE_SLUG );
				submit_button();
				?>
			</form>
		</div>
		<?php
	}
}
