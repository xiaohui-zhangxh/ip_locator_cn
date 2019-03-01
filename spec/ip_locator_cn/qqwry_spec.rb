ips = {
  '171.221.4.111' => {
    country: '中国',
    province: '四川',
    city: '成都市',
    county: '',
    area: '中国四川成都市电信',
    isp: '电信',
    ip: '171.221.4.111',
    origin_country: '四川省成都市',
    origin_area: '电信'
  },
  '60.195.153.98' => {
    country: '中国',
    province: '北京',
    city: '顺义区',
    county: '',
    area: '中国北京顺义区后沙峪金龙网吧',
    isp: '',
    ip: '60.195.153.98',
    origin_country: '北京市顺义区',
    origin_area: '后沙峪金龙网吧'
  },
  '1.24.40.1' => {
    country: '中国',
    province: '内蒙古',
    city: '',
    county: '',
    area: '中国内蒙古联通',
    isp: '联通',
    ip: '1.24.40.1',
    origin_country: '内蒙古锡林郭勒盟',
    origin_area: '联通'
  },
  '171.90.122.168' => {
    country: '中国',
    province: '四川',
    city: '',
    county: '',
    area: '中国四川电信',
    isp: '电信',
    ip: '171.90.122.168',
    origin_country: '四川省凉山州',
    origin_area: '电信'
  }
}

RSpec.describe IpLocatorCn::QQWry do
  context 'extract extract_location' do
    let(:resolver) { IpLocatorCn::QQWry.new }
    it '四川省成都市高新区' do
      expect(resolver.extract_location('四川省成都市高新区')).to eq(
        country: '中国',
        province: '四川',
        city: '成都市',
        county: '高新区'
      )
    end
  end

  context 'with local dat file' do
    before :all do
      @resolver ||= IpLocatorCn::QQWry.new(dat_path: IpLocatorCn.data_path)
    end

    ips.each_pair do |ip, info|
      it "resolve #{ip} to #{info[:area]}" do
        expect(@resolver.resolve(ip)).to eq(info)
      end
    end
  end

  context 'with live dat' do
    before :all do
      @resolver ||= IpLocatorCn::QQWry.new(live_dat: true)
    end

    ips.each_pair do |ip, info|
      it "resolve #{ip} to #{info[:area]}" do
        expect(@resolver.resolve(ip)).to eq(info)
      end
    end
  end
end
