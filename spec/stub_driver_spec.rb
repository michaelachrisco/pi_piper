require 'spec_helper'

describe StubDriver do

  let(:stub_driver){StubDriver.new()}

  before do
    @logger = double()
    @driver = StubDriver.new(:logger => @logger)
  end

  describe '#pin_input' do

    it 'should set pin as input' do
      stub_driver.pin_input(10)
      stub_driver.pin_direction(10).should == :in
    end

    it 'should log that pin is set' do
      @logger.expects(:debug).with('Pin #10 -> Input')
      @driver.pin_input(10)
    end

  end

  describe '#pin_output' do

    it 'should set pin as output' do
      stub_driver.pin_output(10)
      stub_driver.pin_direction(10).should == :out
    end

    it 'should log that pin is set' do
      @logger.expects(:debug).with('Pin #10 -> Output')
      @driver.pin_output(10)
    end

  end

  describe '#pin_set' do

    it 'should set pin value' do
      stub_driver.pin_set(22, 42)
      stub_driver.pin_read(22).should == 42
    end

    it 'should log the new pin value' do
      @logger.expects(:debug).with('Pin #21 -> 22')
      @driver.pin_set(21, 22)
    end

  end

  describe '#pin_set_pud' do
    it 'should set pin value' do
      stub_driver.pin_set_pud(12, Pin::GPIO_PUD_UP)
      stub_driver.pin_read(12).should == Pin::GPIO_HIGH
    end

    it 'should not overwrite set value' do
      stub_driver.pin_set(12,0)
      stub_driver.pin_set_pud(12, Pin::GPIO_PUD_DOWN)
      stub_driver.pin_read(12).should == Pin::GPIO_LOW
    end

    it 'should log the new pin value' do
      @logger.expects(:debug).with('PinPUD #21 -> 22')
      @driver.pin_set_pud(21, 22)
    end
  end

  describe '#spidev_out' do
    it "should log the array sent to ada_spi_out" do
      @logger.expects(:debug).with("SPIDEV -> \u0000\u0001\u0002")
      @driver.spidev_out([0x00,0x01,0x02])
    end
  end

  describe '#spi_begin' do
    it 'should should clear spi data' do
      @logger.expects(:debug)
      @driver.spi_transfer_bytes([0x01,0x02])
      @logger.expects(:debug).with("SPI Begin")
      @driver.spi_begin
      @driver.send(:spi_data).should == []
    end
  end

  describe '#spi_transfer_bytes' do
    it 'should log and store sent data' do
      @logger.expects(:debug).with("SPI CS0 <- [1, 2, 3]")
      @driver.spi_transfer_bytes([0x01, 0x02, 0x03])
      @driver.send(:spi_data).should == [0x01, 0x02, 0x03]
    end
  end

  describe '#spi_chip_select' do
    it 'should return default 0 if nothing provided' do
      @logger.expects(:debug).with("SPI Chip Select = 0")
      @driver.spi_chip_select.should == 0
    end

    it 'should set chip select value if passed in' do
      @logger.expects(:debug).with("SPI Chip Select = 3").twice
      @driver.spi_chip_select(3)
      @driver.spi_chip_select.should == 3
    end
  end


  describe '#reset' do
    it 'should not reset unless asked' do
      StubDriver.new()
      StubDriver.pin_set(1,3)
      StubDriver.pin_read(1).should == 3
      StubDriver.reset
      StubDriver.pin_read(1).should be_nil
    end
  end

end
