ips = {
  '171.221.4.111' => {
    country: '中国',
    province: '四川',
    city: '成都市',
    county: '',
    area: '中国四川成都市电信',
    isp: '电信',
    ip: '171.221.4.111'
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
    let(:resolver) { IpLocatorCn::QQWry.new(dat_path: IpLocatorCn.data_path) }

    ips.each_pair do |ip, info|
      it "resolve #{ip} to #{info[:area]}" do
        expect(resolver.resolve(ip)).to eq(info)
      end
    end
  end

  context 'with live dat' do
    let(:resolver) { IpLocatorCn::QQWry.new(live_dat: true) }
    ips.each_pair do |ip, info|
      it "resolve #{ip} to #{info[:area]}" do
        expect(resolver.resolve(ip)).to eq(info)
      end
    end
  end
end
