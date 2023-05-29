require 'ip_locator_cn/version'
require 'ip_locator_cn/qqwry'

module IpLocatorCn
  # embeded qqwry.dat
  def self.data_path
    File.expand_path('../../data/qqwry.dat', __FILE__)
  end

  # download url for qqwry.rar (uncracked)
  def self.live_data_url
    'http://update.cz88.net/ip/qqwry.rar'
  end

  def self.copywrite_url
    'http://update.cz88.net/ip/copywrite.rar'
  end

  def self.resolve(ip, options={ dat_path: data_path })
    QQWry.new(**options).resolve(ip)
  end
end
