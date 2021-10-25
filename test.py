#!/usr/bin/env python3

from dataclasses import dataclass

@dataclass
class bankpointer:
	addr:	int
	bank:	int

@dataclass
class zsmheader:
    loop = 		bankpointer(0,0xff)		# 3 bytes
    pcm =		bankpointer(0,0)		# 3 bytes
    chanmask:	int	= 0					# 3 bytes (24 flags)
    rate:		int	= 60				# 2 bytes (HZ of framerate)
    pad:		int = 5					# number of pad bytes (reserved bytes)

class zsmfile:
	prghdr = 0xa000
	empty = True
	dirty = False
	totalticks = 0
	
	def __init__(self, filename, playrate):
		self.filename = filename
		self.header = zsmheader()
		self.header.rate = playrate
		ticksperframe = self.header.rate

	def ymwrite(self, reg,val):
		print("YM written");
		
	def psgwrite(self, reg,val):
		print("PSG written");
		
	def pcmwrite(self,reg,val):
		print("PCM written");
		
	def sync():
		psg.sync()
		ym.sync()
		pcm.sync()
		
		
	def wait(self,ticks):
		if (self.empty == True):
			return
		self.totalticks += ticks
		self.ticks += ticks
		if (self.ticks / self.ticksperframe >= 1)
			print("ZSM: New frame")
			if(self.sync() == True):
				
class ym_chip:
	def sync(self):
		return
		
class psg_chip:
	def sync(self):
		return
		
class pcm_chip:
	def sync(self):
		return
	
zsm = zsmfile("bgm.zsm",60)
zsm.info()
