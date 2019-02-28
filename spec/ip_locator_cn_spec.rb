RSpec.describe IpLocatorCn do
  it 'qqwry.dat should exists' do
    expect(File.exist?(subject.data_path)).to be true
  end

  it do
    expect(subject.live_data_url).to eq('http://update.cz88.net/ip/qqwry.rar')
  end

  it do
    expect(subject.copywrite_url).to eq('http://update.cz88.net/ip/copywrite.rar')
  end

  it do
    should respond_to(:resolve)
  end

  it '.resolve(ip) should works' do
    expect(subject.resolve('171.221.4.111')).to eq(
      country: '中国',
      province: '四川',
      city: '成都市',
      county: '',
      area: '中国四川成都市电信',
      isp: '电信',
      ip: '171.221.4.111'
    )
  end

end
