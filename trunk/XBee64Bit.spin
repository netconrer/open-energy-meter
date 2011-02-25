OBJ
  uarts :       "pcFullDuplexSerial4FC"

VAR
  byte  port
  byte  receiveBuffer[200]
  byte  rxData[200]
  byte  dataSet[200]
  word  rxLength
  word  rxNetworkAddress16
  long  rxRemoteAddressUpper32
  long  rxRemoteAddressLower32


PUB initialize(_serialPort)
  port := _serialPort




PUB receivePacket(_escaped) | char, index, length, checksum, j
  'clear lenght and checksum to 0
  length~
  checksum~
  'receive bytes until we get a 0x7E
  repeat until (char := uarts.rx(port)) == $7E
  'get a byte, escape it if needed, and make it the first length
  'word by shifting it 8 bits to the left
  char := uarts.rxtime(port, 1)
  if char == $7D AND _escaped
    length |= (uarts.rx(port) ^ $20) << 8
  else
    length |= char << 8
  'do the same, but don't shift this time, since the next byte
  'is the lowsest signifigant byte of the length word
  char := uarts.rxtime(port, 1)
  if char == $7D AND _escaped
    length |= (uarts.rx(port) ^ $20)
  else
    length |= char
  'clear index to 0
  index~
  'repeat length times
  repeat while index < length + 1
    char := uarts.rx(port)
    'need to un-escape it
    '0x7D indicates that the next byte is the actual byte
    'we ignore the 0x7D and use the next byte
    if char == $7D
      'XOR the char with 0x20
      receiveBuffer[index] := uarts.rx(port) ^ $20
    'not an escaped byte, take it as is
    else
      receiveBuffer[index] := char
    'calculate checksun with every iteration of the loop
    'advance the index variable by 1
    checksum += receiveBuffer[index++]
  'AND checksum with 0xFF do keep only the lower 8 bits
  checksum &= $FF
  'if we have a valid packet, all the bytes after lenght, including
  'the last byte, checksum, added together equal 0xFF
  if checksum <> $FF
    'checksum didn't check out, return -1 to the caller
    return -1
  'so far, this receive method only accounts for packets
  'sent from other XBee modules, not acknowlege packets
  'or various status packets
  case receiveBuffer[0]
    'if the first byte after length is 0x90, we are dealing
    'with received packet from another XBee module
    'subtract 12 from length, since the user is only concerned with
    'the length of the meaningful data in the packet, not addresses
    'and such, since they are static, and always the same length
    $90:  rxLength := length-12
          'shift then AND bytes 1..4 to get the upper 32 bit address
          'of the sending module
          rxRemoteAddressUpper32 := receiveBuffer[1] << 24| receiveBuffer[2] << 16 | receiveBuffer[3] << 8 | receiveBuffer[4]
          'shift then AND bytes 5..8 to get the lower 32 bit address
          'of the sending module
          rxRemoteAddressLower32 := receiveBuffer[5] << 24 | receiveBuffer[6] << 16 | receiveBuffer[7] << 8 | receiveBuffer[8]
          'shift then AND bytes 10..11 to get the 16 bit network address
          rxNetworkAddress16 := receiveBuffer[10] << 8 | receiveBuffer[11]
          'move the important data from receiveBuffer[] to rxData[]
          'so the caller can access it
          bytemove(@rxData, @receiveBuffer[12], rxLength)
          'return 0x90 to the caller, so it knows an rx packet was
          'received
          return $90




PUB apiArray(_64BitDestinationAddressUpper, _64BitDestinationAddressLower, _16BitNetworkAddress, _arrayAddress, _arraySize, _frameId, _escaped) | Length, chars, checkSum,ptr,sourceArrayPtr
	  'clear the index
	  ptr := 0
	  'add 0x7E to byte 0 of array
	  dataSet[ptr++] := $7E
	  '_arraySize is set by caller, we have to add 14 to it
	  'to account for the added bytes API mode requires
	  Length := 14 + _arraySize
	  'add MSB of length to array
	  'add LSB of length to array
	  dataSet[ptr++] := Length.byte[1]
	  dataSet[ptr++] := Length.byte[0]
	  'add 0x10 to indicade a TX request API packet
	  dataSet[ptr++] := $10
	  'add frame id, value passed in but isn't important
	  dataSet[ptr++] := _FrameID
	  'the remote 64 bit address is passed by caller
	  'in two longs, we need to split up those 2 longs
	  'into 8 bytes and add them to the array
	  dataSet[ptr++] := _64BitDestinationAddressUpper.byte[3]
	  dataSet[ptr++] := _64BitDestinationAddressUpper.byte[2]
	  dataSet[ptr++] := _64BitDestinationAddressUpper.byte[1]
	  dataSet[ptr++] := _64BitDestinationAddressUpper.byte[0]
	  dataSet[ptr++] := _64BitDestinationAddressLower.byte[3]
	  dataSet[ptr++] := _64BitDestinationAddressLower.byte[2]
	  dataSet[ptr++] := _64BitDestinationAddressLower.byte[1]
	  dataSet[ptr++] := _64BitDestinationAddressLower.byte[0]
	  'the 16 bit network address is passed by caller
	  'as a word, we need to split it into 2 bytes
	  dataSet[ptr++] := _16BitNetworkAddress.byte[1]
	  dataSet[ptr++] := _16BitNetworkAddress.byte[0]
	  'unimportant, but the XBee expects these two bytes
	  dataSet[ptr++] := $00
	  dataSet[ptr++] := $00
	  'the caller passed us the address to a byte array
	  'that is in HUB memory, the caller also passed
	  'in _arraySize, so we know how many bytes from that
	  'array to read. Jut loop until we have read all the
	  'bytes and written them into our array
	  repeat sourceArrayPtr from 0 to _arraySize - 1
	    dataSet[ptr++] := byte[_arrayAddress++]
	  'start with checksum equals 0xFF, then we subtract all
	  'the bytes we encounter in our outgoing packet until
	  'we reach the end
	  checkSum := $FF
	  Repeat chars from 3 to ptr-1
	    checkSum -= dataSet[chars]
	  'add our calculated checksum to the end off the array
	  dataSet[ptr] := checkSum
	  'if in escaped mode, loop through our outgoing
	  'array and escape any characters as necessary
	  'send them on the fly to the XBEee module
	  'there's no need to store them in memory first
          tx(dataSet[0])
          if (_escaped)
	    Repeat chars from 1 to ptr
	      if (dataSet[chars] == $7E OR dataSet[chars] == $7D OR dataSet[chars] == $11 or dataSet[chars] == $13)
	        tx($7D)
	        tx(dataSet[chars] ^ $20)
	      else
	        tx(dataSet[chars])
          else
	    Repeat chars from 1 to ptr
	      tx(dataSet[chars])




PUB tx(_theChar)
  uarts.tx(port, _theChar)



PUB receivedData
  return @rxData




PUB receivedDataLength
  return rxLength



PUB receivedNetworkAddress
  return rxNetworkAddress16



PUB receivedRemoteAddressUpper
  return rxRemoteAddressUpper32




PUB receivedRemoteAddressLower
  return rxRemoteAddressLower32
