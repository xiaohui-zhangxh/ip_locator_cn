# IP Locator CN [![Gem Version](https://badge.fury.io/rb/ip_locator_cn.svg)](https://badge.fury.io/rb/ip_locator_cn) [![Build Status](https://travis-ci.org/xiaohui-zhangxh/ip_locator_cn.svg?branch=master)](https://travis-ci.org/xiaohui-zhangxh/ip_locator_cn) [![Maintainability](https://api.codeclimate.com/v1/badges/ce57ddef67adc3d48378/maintainability)](https://codeclimate.com/github/xiaohui-zhangxh/ip_locator_cn/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/ce57ddef67adc3d48378/test_coverage)](https://codeclimate.com/github/xiaohui-zhangxh/ip_locator_cn/test_coverage)

基于纯真 IP 库解析中国的 IP，参考了“[纯真数据库自动更新原理](https://github.com/shuax/QQWryUpdate/blob/master/update.php)” 和 “[PHP 版本的 IP 搜索源码](https://github.com/itbdw/ip-database/blob/master/src/IpLocation.php)”

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ip_locator_cn'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ip_locator_cn

## Usage

从 Gem 包集成的 qqwry.dat 数据库解析 IP：

```ruby
2.4.5 :001 > require 'ip_locator_cn'
 => true
2.4.5 :002 > IpLocatorCn.resolve('60.195.153.98')
 => {:province=>"北京", :city=>"顺义区", :country=>"中国", :ip=>"60.195.153.98", :county=>"", :isp=>"", :area=>"中国北京顺义区后沙峪金龙网吧", :origin_country=>"北京市顺义区", :origin_area=>"后沙峪金龙网吧"}
```

在线下载并解码 qqwry.dat ，然后解析 IP：

```ruby
2.4.5 :001 > require 'ip_locator_cn'
 => true
2.4.5 :002 > IpLocatorCn.resolve('60.195.153.98', live_dat: true)
 => {:province=>"北京", :city=>"顺义区", :country=>"中国", :ip=>"60.195.153.98", :county=>"", :isp=>"", :area=>"中国北京顺义区后沙峪金龙网吧", :origin_country=>"北京市顺义区", :origin_area=>"后沙峪金龙网吧"}
```

开启调试信息：

```ruby
2.4.5 :001 > require 'ip_locator_cn'
 => true
2.4.5 :002 > IpLocatorCn.resolve('60.195.153.98', live_dat: true, debug: true)
[2019-03-01 17:37:46 +0800] => downloading http://update.cz88.net/ip/copywrite.rar
[2019-03-01 17:37:46 +0800] => downloading http://update.cz88.net/ip/qqwry.rar
[2019-03-01 17:37:49 +0800] => qqwry decoding key is 225
[2019-03-01 17:37:49 +0800] => total ip ranges: 472217
[2019-03-01 17:37:53 +0800] => pos is 6658343
[2019-03-01 17:37:53 +0800] => begin_ip is 60.195.153.0
[2019-03-01 17:37:53 +0800] => endip is 60.195.153.255
[2019-03-01 17:37:53 +0800] => offset is 696416
[2019-03-01 17:37:53 +0800] => country is 北京市顺义区
[2019-03-01 17:37:53 +0800] => area is 后沙峪金龙网吧
 => {:province=>"北京", :city=>"顺义区", :country=>"中国", :ip=>"60.195.153.98", :county=>"", :isp=>"", :area=>"中国北京顺义区后沙峪金龙网吧", :origin_country=>"北京市顺义区", :origin_area=>"后沙峪金龙网吧"}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xiaohui-zhangxh/ip_locator_cn.

### Test

```bash
bundle exec rspec
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
