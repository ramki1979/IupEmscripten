/** \file
 * \brief Image Resource.
 *
 * See Copyright Notice in "iup.h"
 */

#import <Cocoa/Cocoa.h>

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

#include "iup.h"

#include "iup_object.h"
#include "iup_attrib.h"
#include "iup_str.h"
#include "iup_image.h"

#include "iupcocoa_drv.h"

/*
int GetRowBytes(int width,int inPixelDepth)
{
	return (((width * inPixelDepth + 15) / 16) * 2);
}
 */

void iupdrvImageGetRawData(void* handle, unsigned char* imgdata)
{
  int x,y;
  unsigned char *red,*green,*blue,*alpha;
  NSImage *image = (__bridge NSImage*)handle;
  NSBitmapImageRep *bitmap = nil;
  if([[image representations] count]>0) bitmap = [[image representations] objectAtIndex:0];
  if(bitmap==nil) return;
	NSInteger w = [bitmap pixelsWide];
  NSInteger h = [bitmap pixelsHigh];
  NSInteger bpp = [bitmap bitsPerPixel];
  NSInteger planesize = w*h;
  unsigned char *bits = [bitmap bitmapData]; 
  red = imgdata;
  green = imgdata+planesize;
  blue = imgdata+2*planesize;
  alpha = imgdata+3*planesize;
  for(y=0;y<h;y++) {
    for(x=0;x<w;x++) {
      if(bpp>=24) {
        *red++ = *bits++;
        *green++ = *bits++;
        *blue++ = *bits++;
      }
      if(bpp==32) {
        *alpha++ = *bits++;
      }
    }
  }
}

void* iupdrvImageCreateImageRaw(int width, int height, int bpp, iupColor* colors, int colors_count, unsigned char *imgdata)
{
  int x,y;
  unsigned char *red,*green,*blue,*alpha;
  void *theArray[1];
  unsigned char *pixels = malloc(width*height*bpp);
  theArray[0] = (void*)pixels;
  int planesize = width*height;
  red = imgdata;
  green = imgdata+planesize;
  blue = imgdata+2*planesize;
  alpha = imgdata+3*planesize;
  for(y=0;y<height;y++){
    for(x=0;x<width;x++) {
      *pixels++ = *red++;
      *pixels++ = *green++;
      *pixels++ = *blue++;
      if(bpp==32)
        *pixels++ = *alpha;
    }
  }
	NSBitmapImageRep* theRep;
	
if(bpp==32)
{
 theRep=[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:(unsigned char **)&theArray
			pixelsWide:width pixelsHigh:height bitsPerSample:8
				samplesPerPixel:4 hasAlpha:YES isPlanar:NO
				colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:0
				bitsPerPixel:bpp];
}
else
{
	theRep=[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:(unsigned char **)&theArray
												   pixelsWide:width pixelsHigh:height bitsPerSample:8
											  samplesPerPixel:3 hasAlpha:NO isPlanar:NO
											   colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:0
												 bitsPerPixel:bpp];
}
  NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width,height)];
  [image addRepresentation:theRep];
  return (void*)CFBridgingRetain(image);
}

int iupdrvImageGetRawInfo(void* handle, int *w, int *h, int *bpp, iupColor* colors, int *colors_count)
{
  /* How to get the pallete? */
  (void)colors;
  (void)colors_count;
  return iupdrvImageGetInfo(handle, w, h, bpp);
}

void* iupdrvImageCreateImage(Ihandle *ih, const char* bgcolor, int make_inactive)
{
  int y, x, bpp, bgcolor_depend = 0,
      width = ih->currentwidth,
      height = ih->currentheight;
  unsigned char *imgdata = (unsigned char*)iupAttribGetStr(ih, "WID");
  unsigned char bg_r=0, bg_g=0, bg_b=0;
  bpp = iupAttribGetInt(ih, "BPP");
  iupStrToRGB(bgcolor, &bg_r, &bg_g, &bg_b);

  NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width,height)];
  if (!image)
    return NULL;
  unsigned char *red,*green,*blue,*alpha;
	unsigned char* source_pixel;
  void *theArray[1];
//  unsigned char *pixels = malloc(width*height*bpp);
	unsigned char *pixels = malloc(width*height*32);
  theArray[0] = (void*)pixels;
  int planesize = width*height;

	source_pixel = imgdata;
	red = imgdata;

	/*
green = imgdata+planesize;
  blue = imgdata+2*planesize;
  alpha = imgdata+3*planesize;
*/
	green = imgdata+1;
	blue = imgdata+2;
	alpha = imgdata+3;
	
  for(y=0;y<height;y++){
    for(x=0;x<width;x++) {
/*
		*pixels++ = *red++;
      *pixels++ = *green++;
      *pixels++ = *blue++;
*/
		*pixels = *source_pixel;
		pixels++;
		source_pixel++;
		
		*pixels = *source_pixel;
		pixels++;
		source_pixel++;

		*pixels = *source_pixel;
		pixels++;
		source_pixel++;

		
		if(make_inactive) {
        unsigned char r = *(pixels-3),
                      g = *(pixels-2),
                      b = *(pixels-1);
        iupImageColorMakeInactive(&r, &g, &b, bg_r, bg_g, bg_b);
      }
      if(bpp==32)
	  {
     //   *pixels++ = *alpha++;
		  
		  *pixels = *source_pixel;
		  pixels++;
		  source_pixel++;
	  }
      else
	  {
  //      *pixels++ = 255;
		  
		  *pixels = 255;
		  pixels++;
	  }
    }
  }
	NSBitmapImageRep *theRep;
	
	/*
	theRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:(unsigned char **)&theArray
			pixelsWide:width pixelsHigh:height bitsPerSample:8
				samplesPerPixel:4 hasAlpha:YES isPlanar:NO
				colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:GetRowBytes(width,4)
				bitsPerPixel:32];
	*/
	
	
	theRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:(unsigned char **)&theArray
													 pixelsWide:width pixelsHigh:height bitsPerSample:8
												samplesPerPixel:4 hasAlpha:YES isPlanar:NO
												 colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:width*4
												   bitsPerPixel:32];
	
	
  [image addRepresentation:theRep];
  if (bgcolor_depend || make_inactive)
    iupAttribSetStr(ih, "_IUP_BGCOLOR_DEPEND", "1");

  return (void*)CFBridgingRetain(image);
}

void* iupdrvImageCreateIcon(Ihandle *ih)
{
  return iupdrvImageCreateImage(ih, NULL, 0);
}

void* iupdrvImageCreateCursor(Ihandle *ih)
{
  int bpp,y,x,hx,hy,
      width = ih->currentwidth,
      height = ih->currentheight,
      line_size = (width+7)/8,
      size_bytes = line_size*height;
  unsigned char *imgdata = (unsigned char*)iupAttribGetStr(ih, "WID");
  char *sbits, *mbits, *sb, *mb;
  unsigned char r, g, b;

  bpp = iupAttribGetInt(ih, "BPP");
  if (bpp > 8)
    return NULL;

  sbits = (char*)malloc(2*size_bytes);
  if (!sbits) return NULL;
  memset(sbits, 0, 2*size_bytes);
  mbits = sbits + size_bytes;

  sb = sbits;
  mb = mbits;
  for (y=0; y<height; y++)
  {
    for (x=0; x<width; x++)
    {
      int byte = x/8;
      int bit = x%8;
      int index = (int)imgdata[y*width+x];
      /* index==0 is transparent */
      if (index == 1)
        sb[byte] = (char)(sb[byte] | (1<<bit));
      if (index != 0)
        mb[byte] = (char)(mb[byte] | (1<<bit));
    }

    sb += line_size;
    mb += line_size;
  }

  hx=0; hy=0;
  iupStrToIntInt(iupAttribGet(ih, "HOTSPOT"), &hx, &hy, ':');

  NSData *tiffData = [NSData dataWithBytes:imgdata length:(width*height*(bpp/8))];
  NSImage *source = [[NSImage alloc] initWithData:tiffData];
  NSSize size = {width,height};
  [source setSize:size]; 

  NSPoint point = {hx,hy};

  NSCursor *cursor = [[NSCursor alloc] initWithImage:source hotSpot:point];

  free(sbits);
  return (void*)CFBridgingRetain(cursor);
}

void* iupdrvImageCreateMask(Ihandle *ih)
{
  int bpp,y,x,
      width = ih->currentwidth,
      height = ih->currentheight,
      line_size = (width+7)/8,
      size_bytes = line_size*height;
  unsigned char *imgdata = (unsigned char*)iupAttribGetStr(ih, "WID");
  char *bits, *sb;
  unsigned char colors[256];

  bpp = iupAttribGetInt(ih, "BPP");
  if (bpp > 8)
    return NULL;

  bits = (char*)malloc(size_bytes);
  if (!bits) return NULL;
  memset(bits, 0, size_bytes);

  iupImageInitNonBgColors(ih, colors);

  sb = bits;
  for (y=0; y<height; y++)
  {
    for (x=0; x<width; x++)
    {
      int byte = x/8;
      int bit = x%8;
      int index = (int)imgdata[y*width+x];
      if (colors[index])
        sb[byte] = (char)(sb[byte] | (1<<bit));
    }

    sb += line_size;
  }

  NSData *tiffData = [NSData dataWithBytes:imgdata length:(width*height*(bpp/8))];
  NSImage *mask = [[NSImage alloc] initWithData:tiffData];
  NSSize size = {width,height};
  [mask setSize:size]; 
  free(bits);
  return (void*)CFBridgingRetain(mask);
}

void* iupdrvImageLoad(const char* name, int type)
{
  //int iup2mac[3] = {IMAGE_BITMAP, IMAGE_ICON, IMAGE_CURSOR};
  NSImage *image;
  NSString *path = [[NSString alloc] initWithUTF8String:name];
  image = [[NSImage alloc] initWithContentsOfFile: path];
  NSBitmapImageRep *rep = [[image representations] objectAtIndex: 0];
  // If you think you might get something other than a bitmap image representation,
  // check for it here.

  NSSize size = NSMakeSize ([rep pixelsWide], [rep pixelsHigh]);
  [image setSize: size];
  
  return (void*)CFBridgingRetain(image);
}

int iupdrvImageGetInfo(void* handle, int *w, int *h, int *bpp)
{
  NSImage *image = (__bridge NSImage*)handle;
  NSBitmapImageRep *bitmap = nil;
  if([[image representations] count]>0) bitmap = [[image representations] objectAtIndex:0];
  if(bitmap==nil) return 0;
  if(w) *w = [bitmap pixelsWide];
  if(h) *h = [bitmap pixelsHigh];
  if(bpp) *bpp = [bitmap bitsPerPixel];
  return 1;
}

// [NSApp setApplicationIconImage: [NSImage imageNamed: @"Icon_name.icns"]]

void iupdrvImageDestroy(void* handle, int type)
{
#if __has_feature(objc_arc)
	NSImage* image = CFBridgingRelease(handle);
	
#else
  switch (type)
  {
  case IUPIMAGE_IMAGE:
    [handle release];
    break;
  case IUPIMAGE_ICON:
    [handle release];
    break;
  case IUPIMAGE_CURSOR:
    [handle release];
    break;
  }
#endif
}

