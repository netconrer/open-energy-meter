'' Copyright (c) 2011 Jay Kickliter, Frank Lynum
'' Released under MIT license, see end of file for terms of use

OBJ
  fft           : "heater_fft"
  uarts         : "pcFullDuplexSerial4FC"
  f32           : "f32"
  floatString   : "FloatString"


VAR
  long  vx[fft#FFT_SIZE]
  long  vy[fft#FFT_SIZE]
  long  ix[fft#FFT_SIZE]
  long  iy[fft#FFT_SIZE]
  long  voltageSampleAddress
  long  currentSampleAddress
  long  powerFactorWriteAddress
  long  frequencyWriteAddress
  long  fft_mailbox_cmd          'Command
  long  fft_mailbox_bxp          'Address of x buffer
  long  fft_mailbox_byp          'Address of y buffer
  long  stack[100]
  long  powerFactorPtr
  long  frequencyPtr
  long  voltageSamplePtr
  long  currentSamplePtr
  long  voltageOffsetPtr
  long  currentOffsetPtr

PUB start(_voltageSamplePtr, _currentSamplePtr, _powerFactorPtr, _frequencyPtr, _voltageOffsetPtr, _currentOffsetPtr) | temp
  voltageSamplePtr := _voltageSamplePtr
  currentSamplePtr := _currentSamplePtr
  powerFactorPtr   := _powerFactorPtr
  frequencyPtr     := _frequencyPtr
  voltageOffsetPtr := _voltageOffsetPtr
  currentOffsetPtr := _currentOffsetPtr

  fft.start(@fft_mailbox_cmd)

  cognew(freqAndPowerFactorLoop, @stack)
  uarts.dec(1, f32.start)


PUB freqAndPowerFactorLoop | timer , i, pf
  repeat
    timer := cnt
    repeat i from 0 to 1023
      waitcnt(timer += clkfreq/1024)
      vx[i] := long[voltageSamplePtr]>>1
      ix[i] := long[currentSamplePtr]>>1
      vy[i] := 0
      iy[i] := 0
    fft.butterflies(fft#CMD_DECIMATE | fft#CMD_BUTTERFLY, @vx, @vy)
    fft.butterflies(fft#CMD_DECIMATE | fft#CMD_BUTTERFLY, @ix, @iy)
    pf := f32.fabs(f32.cos(f32.fsub(f32.atan2(f32.ffloat(vy[60]), f32.ffloat(vx[60])), f32.atan2(f32.ffloat(iy[60]), f32.ffloat(ix[60])))))
    long[powerFactorPtr] := pf
    long[voltageOffsetPtr] := ^^(vx[0]^2 + vy[0]^2)*2
    long[currentOffsetPtr] := ^^(ix[0]^2 + iy[0]^2)*2



PUB outputPowerFactor | pf
  uarts.newline(1)
  uarts.str(1, string("Power factor: "))
  pf := f32.cos(f32.fsub(f32.atan2(f32.ffloat(vy[60]), f32.ffloat(vx[60])), f32.atan2(f32.ffloat(iy[60]), f32.ffloat(ix[60]))))
  pf := f32.ftrunc(f32.fmul(pf, 10000.0))
  uarts.dec(1, pf)



PUB outputOffsets
  uarts.str(1, string("Voltage Offset      Current Offset"))
  uarts.newline(1)
  uarts.dec(1, ^^(vx[0]^2 + vy[0]^2)*2)
  uarts.str(1, string("        "))
  uarts.dec(1, ^^(ix[0]^2 + iy[0]^2)*2)
  uarts.newline(1)



PUB outputFFTResults | i
'Spectrum is available in first half of the buffers after FFT.
    uarts.str(1, string("f     v(real)  v(imag)  i(real)  i(imag)"))
    uarts.newline(1)
    repeat i from 50 to 70' (fft#FFT_SIZE / 2)
        uarts.decf(1, i, 3)
        uarts.str(1, string("   "))
        uarts.decf(1, vx[i], 6)
        uarts.str(1, string("   "))
        uarts.decf(1, vy[i], 6)
        uarts.str(1, string("   "))
        uarts.decf(1, ix[i], 6)
        uarts.str(1, string("   "))
        uarts.decf(1, iy[i], 6)
        uarts.newline(1)





'Permission is hereby granted, free of charge, to any person obtaining a copy
'of this software and associated documentation files (the "Software"), to deal
'in the Software without restriction, including without limitation the rights
'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
'copies of the Software, and to permit persons to whom the Software is
'furnished to do so, subject to the following conditions:

'The above copyright notice and this permission notice shall be included in
'all copies or substantial portions of the Software.

'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
'THE SOFTWARE.
