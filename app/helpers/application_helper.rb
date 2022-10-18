# frozen_string_literal: true

# Application level helper methods.
module ApplicationHelper
  def us_states # rubocop:disable Metrics/MethodLength
    [
      ['', nil],
      %w[Alabama AL],
      %w[Alaska AK],
      %w[Arizona AZ],
      %w[Arkansas AR],
      %w[California CA],
      %w[Colorado CO],
      %w[Connecticut CT],
      %w[Delaware DE],
      ['District of Columbia', 'DC'],
      %w[Florida FL],
      %w[Georgia GA],
      %w[Hawaii HI],
      %w[Idaho ID],
      %w[Illinois IL],
      %w[Indiana IN],
      %w[Iowa IA],
      %w[Kansas KS],
      %w[Kentucky KY],
      %w[Louisiana LA],
      %w[Maine ME],
      %w[Maryland MD],
      %w[Massachusetts MA],
      %w[Michigan MI],
      %w[Minnesota MN],
      %w[Mississippi MS],
      %w[Missouri MO],
      %w[Montana MT],
      %w[Nebraska NE],
      %w[Nevada NV],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      %w[Ohio OH],
      %w[Oklahoma OK],
      %w[Oregon OR],
      %w[Pennsylvania PA],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      %w[Tennessee TN],
      %w[Texas TX],
      %w[Utah UT],
      %w[Vermont VT],
      %w[Virginia VA],
      %w[Washington WA],
      ['West Virginia', 'WV'],
      %w[Wisconsin WI],
      %w[Wyoming WY]
    ]
  end

  def authorized?(action, entity, record = nil)
    Authorizer.new(
      user: current_user,
      action:,
      entity:,
      record:
    ).run
  end

  def current_class?(path)
    return 'nav-item-active' if request.path.starts_with?(path)

    ''
  end

  def tailwind_classes_for(flash_type)
    {
      notice: 'authenticated-notice',
      error: 'authenticated-error'
    }.stringify_keys[flash_type.to_s] || flash_type.to_s
  end

  def alert_background_for(flash_type)
    flash_type == :notice ? 'text-green-800' : 'text-red-900'
  end
end
