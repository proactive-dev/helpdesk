require 'browser_test_helper'

# Regression test for #2017

class IntegrationCtiNotifyNotClearingOnLeftsideTest < TestCase
  setup do
    if !ENV['CTI_TOKEN']
      raise "ERROR: Need CTI_TOKEN - hint CTI_TOKEN='some_token'"
    end

  end

  def test_notify_badge
    id = rand(99_999_999)

    @browser = browser_instance
    login(
      username: 'master@example.com',
      password: 'test',
      url: browser_url,
    )

    click(css: 'a[href="#manage"]')
    click(css: 'a[href="#system/integration"]')
    click(css: 'a[href="#system/integration/cti"]')

    switch(
      css: '.content.active .js-switch',
      type: 'on'
    )

    watch_for(
      css: 'a[href="#cti"]'
    )

    click(css: 'a[href="#cti"]')

    # simulate cti callbacks

    url = URI.join(browser_url, "api/v1/cti/#{ENV['CTI_TOKEN']}")
    params = { direction: 'in', from: '491715000002', to: '4930600000000', callId: "4991155921769858278-#{id}", cause: 'busy' }
    Net::HTTP.post_form(url, params.merge(event: 'newCall'))
    Net::HTTP.post_form(url, params.merge(event: 'hangup'))

    watch_for(
      css: '.js-phoneMenuItem .counter',
      value: '1'
    )

    click(css: '.content.active .table-checkbox label')

    watch_for_disappear(
      css: '.js-phoneMenuItem .counter'
    )

    click(css: 'a[href="#manage"]')
    click(css: 'a[href="#system/integration"]')
    click(css: 'a[href="#system/integration/cti"]')

    switch(
      css: '.content.active .js-switch',
      type: 'off'
    )
  end
end
