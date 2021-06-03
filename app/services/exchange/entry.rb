class Exchange::Entry
  def self.exchanges
    {
      'huobi' => Exchange::Huobi,
      'bitget' => Exchange::Bitget
    }
  end
end