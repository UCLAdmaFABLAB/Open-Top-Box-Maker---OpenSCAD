//
//    Copyright (c) 2016, Jonathan Cecil, UCLA DMA FABLAB. 
//    
//    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//    
//    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//    
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


// This makes open top box with varying edge notches. We use this for making storage bins.

// EDIT THESE:
width = 14.25; // x measurement
height = 7.625; // z measurement
depth = 17.125; // y measurement
thickness = 0.452; // thickness of material
toolDiameter = 0.25; // toolDiameter used for panel placement only, not for fillets

notchLengthProportion = 4.0; // change to scale notches bigger or smaller

// handle details
makeHandle = true;

handleLength = 6.0;
handleHeight = 1.25;
handleDistanceFromEdge = 1.0;

// fillet section
// useful for cnc
makeFillets = true;

// fillet style dictates where the fillet will be placed
// 0 = inside notch corner
// 1 = set inside the tab
// 2 = set in the side or bottom
filletStyle = 0;

filletDiameter = 0.255;
centeredFilletOffset = sin(45) * (filletDiameter/2.0);

filletCircleResolution = 50;

//
// DON'T EDIT THESE UNLESS YOU WANT TO GET INTO THE WEEDS:
//
echo("width notches", numWidthNotches);
echo("height notches", numHeightNotches);
echo("depth notches", numDepthNotches);

// number notches is always odd so the edges are symetrical
numWidthNotches = ceil(width/(notchLengthProportion*thickness)) + ((( ceil(width/(notchLengthProportion*thickness)-1) % 2)) * 1);
widthNotchLength = width/numWidthNotches;

numHeightNotches = ceil(height/(notchLengthProportion*thickness))+ ((( ceil(height/(notchLengthProportion*thickness)-1) % 2)) * 1);
heightNotchLength = height/numHeightNotches;

numDepthNotches = ceil(depth/(notchLengthProportion*thickness))+ ((( ceil(depth/(notchLengthProportion*thickness)-1) % 2)) * 1);
depthNotchLength = depth/numDepthNotches;

// make bottom
//      0
//     0X0
//      0

MakePanel(width, numWidthNotches, widthNotchLength, 0,
        depth, numDepthNotches, depthNotchLength, 0,
        false);
        
// make the first side
//      X
//     000
//      0

translate([0,(depth/2)+(height/2)+ (2.0 *toolDiameter)])
{
    difference()
    {
        MakePanel(width, numWidthNotches, widthNotchLength, 1, height, numHeightNotches, heightNotchLength, 0, true);
        if (makeHandle)
		{
			// make the handle
			translate( [0, (height/2.0) - handleDistanceFromEdge - (handleHeight/2.0)])
			{
				union()
				{
					square([handleLength - handleHeight, handleHeight], center=true);
					translate([-(handleLength/2.0)+(handleHeight/2.0),0])
					{
						circle(r=(handleHeight/2.0), $fn=64);
					}
					translate([(handleLength/2.0)-(handleHeight/2.0),0])
					{
						circle(r=(handleHeight/2.0), $fn=64);
					}
				}
			}
		}
    }
}


// make the second side
//      0
//     000
//      X
translate([0,-(depth/2)-(height/2)-(2.0*toolDiameter)])
{
    difference()
    {
        rotate(180.0)
        {
            scale([-1.0,1.0])
            {
                MakePanel(width, numWidthNotches, widthNotchLength, 1, height, numHeightNotches, heightNotchLength, 0,
                true);
            }
        }
        if (makeHandle)
		{
			// make the handle
			translate( [0, -(height/2.0) + handleDistanceFromEdge + (handleHeight/2.0)])
			{
				union()
				{
					square([handleLength - handleHeight, handleHeight], center=true);
					translate([-(handleLength/2.0)+(handleHeight/2.0),0])
					{
						circle(r=(handleHeight/2.0), $fn=64);
					}
					translate([(handleLength/2.0)-(handleHeight/2.0),0])
					{
						circle(r=(handleHeight/2.0), $fn=64);
					}
				}
			}
		}
    }
}



// make third side
//      0
//     X00
//      0
translate([-(width/2.0)-(height/2.0)- (2.0*toolDiameter),0])
{
    difference()
    {
        rotate(90.0)
        {
            MakePanel(depth, numDepthNotches, depthNotchLength, 1, height, numHeightNotches, heightNotchLength, 1, true);
        }
        
    }
}



// make fourth side
//      0
//     00X
//      0

translate([(width/2.0)+(height/2.0)+(2.0*toolDiameter),0])
{
    difference()
    {
        rotate(270.0)
        {
            scale([-1.0,1.0])
            {
                MakePanel(depth, numDepthNotches, depthNotchLength, 1, height, numHeightNotches, heightNotchLength, 1, true);
            }
        }
        
    }
}


module MakeNotch(notchLength, notchThickness, notchMakeFillets, notchFilletDiameter, 
        notchCenteredFilletOffset, notchFilletStyle = 0, filletLeft = true, filletRight = true)
{
    square([notchLength,notchThickness*2.0],center=true);
    if (notchMakeFillets == true)
    {
        if (notchFilletStyle == 0)
        {
            translate( [ 0.0, -notchThickness + notchCenteredFilletOffset ])
            {
                if (filletLeft)
                {
                    translate( [(-notchLength/2.0) + notchCenteredFilletOffset, 0.0] )
                    {
                        circle(notchFilletDiameter/2.0, $fn = filletCircleResolution);
                    }
                }
                if (filletRight)
                {
                    translate( [(notchLength/2.0) - notchCenteredFilletOffset, 0.0] )
                    {
                        circle(notchFilletDiameter/2.0, $fn = filletCircleResolution);
                    }
                }
            }
        }
        else if (notchFilletStyle == 1)
        {
            translate( [ 0.0, -notchThickness + (filletDiameter/2.0)])
            {
                if (filletLeft)
                {
                    translate( [-notchLength/2.0, 0.0] )
                    {
                        circle(notchFilletDiameter/2.0, $fn = filletCircleResolution);
                    }
                }
                if (filletRight)
                {
                    translate( [notchLength/2.0, 0.0] )
                    {
                        circle(notchFilletDiameter/2.0, $fn = filletCircleResolution);
                    }
                }
            }
        }
        else if (notchFilletStyle == 2)
        {
            translate( [ 0.0, -notchThickness ])
            {
                if (filletLeft)
                {
                    translate( [-notchLength/2.0 + (filletDiameter/2.0), 0.0] )
                    {
                        circle(notchFilletDiameter/2.0, $fn = filletCircleResolution);
                    }
                }
                if (filletRight)
                {
                    translate( [notchLength/2.0 - (filletDiameter/2.0), 0.0] )
                    {
                        circle(notchFilletDiameter/2.0, $fn = filletCircleResolution);
                    }
                }
            }
        }
    }
}



// Order determines notch order, can be 1 or 0
module MakePanel(panelWidth, panelNumWidthNotches, panelWidthNotchLength, panelWidthOrder,
                panelDepth, panelNumDepthNotches, panelDepthNotchLength, panelDepthOrder,
                side = false)
{
    difference()
    {
        square([panelWidth,panelDepth],center=true);
        for ( i = [0 : panelNumWidthNotches-1] )
        {
            if ( i % 2 == panelWidthOrder)
            {
                translate( [-(panelWidth/2.0) + (panelWidthNotchLength/2.0) + ( i * panelWidthNotchLength),0])
                {
                    if (side == false)
                    {
                        translate( [0, panelDepth/2.0] )
                        {
                            if (i == panelNumWidthNotches-1)
                            {
                                MakeNotch(panelWidthNotchLength, thickness, makeFillets, filletDiameter,
                            centeredFilletOffset, filletStyle, true, false);
                            }
                            else if (i == 0)
                            {
                                MakeNotch(panelWidthNotchLength, thickness, makeFillets, filletDiameter,
                            centeredFilletOffset, filletStyle, false, true);
                            }
                            else
                            {
                                MakeNotch(panelWidthNotchLength, thickness, makeFillets, filletDiameter,
                            centeredFilletOffset, filletStyle);
                            }
                        }
                    }
                    translate( [0, -panelDepth/2.0] )
                    {
                        rotate(180.0)
                        {
                            if (i == 0)
                            {
                                MakeNotch(panelWidthNotchLength, thickness, makeFillets, filletDiameter,
                            centeredFilletOffset, filletStyle, true, false);
                            }
                            else if (i == panelNumWidthNotches-1)
                            {
                                MakeNotch(panelWidthNotchLength, thickness, makeFillets, filletDiameter,
                            centeredFilletOffset, filletStyle, false, true);
                            }
                            else
                            {
                                MakeNotch(panelWidthNotchLength, thickness, makeFillets, filletDiameter,
                            centeredFilletOffset, filletStyle);
                            }
                        }
                    }
                }
            }
        }
        for ( i = [0 : panelNumDepthNotches-1] )
        {
            if ( i % 2 == panelDepthOrder)
            {
                translate( [0,-(panelDepth/2.0) + (panelDepthNotchLength/2.0) + ( i * panelDepthNotchLength)])
                {
                    translate( [panelWidth/2.0,0] )
                    {
                        rotate(270.0)
                        {
                            if (i == 0)
                            {
                                MakeNotch(panelDepthNotchLength, thickness, makeFillets, filletDiameter,
                            centeredFilletOffset, filletStyle, true, false);
                            }
                            else if (i == panelNumDepthNotches-1)
                            {
                                MakeNotch(panelDepthNotchLength, thickness, makeFillets, filletDiameter,
                            centeredFilletOffset, filletStyle, false, true);
                            }
                            else
                            {
                                MakeNotch(panelDepthNotchLength, thickness, makeFillets, filletDiameter,
                            centeredFilletOffset, filletStyle);
                            }
                        }
                    }
                    translate( [-panelWidth/2.0,0] )
                    {
                        rotate(90.0)
                        {
                            if (i == panelNumDepthNotches-1)
                            {
                                MakeNotch(panelDepthNotchLength, thickness, makeFillets, filletDiameter,
                            centeredFilletOffset, filletStyle, true, false);
                            }
                            else if (i == 0)
                            {
                                MakeNotch(panelDepthNotchLength, thickness, makeFillets, filletDiameter,
                            centeredFilletOffset, filletStyle, false, true);
                            }
                            else
                            {
                                MakeNotch(panelDepthNotchLength, thickness, makeFillets, filletDiameter,
                            centeredFilletOffset, filletStyle);
                            }
                        }
                    }
                }
            }
        }
    }

}



