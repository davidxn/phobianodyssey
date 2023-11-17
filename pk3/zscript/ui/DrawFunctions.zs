class DrawFunctions {

	const UI_WIDTH = 400;
	const UI_HEIGHT = 300;
	const UI_SHADE_ALPHA = 0.5;	
	// % vertical space between lines when drawing strings
	const DIALOG_VSPACE = 0.05;

	static ui Vector2 RealToVirtual(Vector2 r)
	{
		Vector2 v;
		double vw, vh, rw, rh;
		vw = UI_WIDTH;
		vh = UI_HEIGHT;
		rw = Screen.GetWidth();
		rh = Screen.GetHeight();
		double realAspect = rw / rh;
		double virtualAspect = vw / vh;
		// pillarbox: aspect correct X axis
		if ( realAspect > virtualAspect )
		{
			// offset for aspect
			// (TODO: below works for 16:9 and 16:10 *and* 17:10 @ 800x480,
			// but not 17:10 @ 1024x600... why?!?)
			double pillarWidth;
			pillarWidth = ((rw * vh) / rh) - vw;
			pillarWidth /= 2;
			double croppedRealWidth = (rh * vw) / vh;
			v.x = vw / croppedRealWidth * r.x;
			v.x -= pillarWidth;
			v.y = (vh / rh) * r.y;
		}
		// letterbox: aspect correct Y axis (eg 5:4)
		else if ( realAspect < virtualAspect )
		{
			v.x = (vw / rw) * r.x;
			double letterBoxHeight;
			letterBoxHeight = ((rh * vw) / rw) - vh;
			letterBoxHeight /= 2;
			double croppedRealHeight = (rw * vh) / vw;
			v.y = vh / croppedRealHeight * r.y;
			v.y -= letterBoxHeight;
		}
		else
		{
			v.x = (vw / rw) * r.x;
			v.y = (vh / rh) * r.y;
		}
		return v;
	}

	static ui void ScreenDrawTextureWithinArea(TextureID tex, double pct_x, double pct_y, double areaW, double areaH, double marginPct = 0, double alpha = 1, bool aspectCorrect = true, bool centerX = false)
	{
		int ix = int(pct_x * UI_WIDTH);
		int iy = int(pct_y * UI_HEIGHT);
		int tw, th;
		[tw, th] = TexMan.GetSize(tex);
		// correct for Doom's nonsquare aspect
		double sqth;
		if ( aspectCorrect )
			sqth = double(th) * (1 + ((320.0 / 200) - (320.0 / 240)));
		else
			sqth = double(th);
		double w, h;
		// scale down to create margin around icon in button
		double marginScale = 1 - marginPct;
		// wide stuff: make shorter, skootch down
		if ( tw >= sqth )
		{
			w = (areaW * marginScale) * UI_WIDTH;
			h = (areaH * marginScale) * UI_HEIGHT / (double(tw) / sqth);
			double yOff = ((areaH * marginScale) * UI_HEIGHT) - h;
			iy += int(yOff / 2);
		}
		// tall stuff: make narrower, skootch right
		else
		{
			w = (areaW * marginScale) * UI_WIDTH * (double(tw) / sqth);
			double xOff = ((areaW * marginScale) * UI_WIDTH) - w;
			ix += int(xOff / 2);
			h = (areaH * marginScale) * UI_HEIGHT;
		}
		// offset for margin
		ix += int(areaW * ((1 - marginScale) / 2) * UI_WIDTH);
		iy += int(areaH * ((1 - marginScale) / 2) * UI_HEIGHT);
		if ( centerX )
			ix -= int(w / 2);
		Screen.DrawTexture(tex, true, ix, iy,
						   DTA_DestWidth, int(w), DTA_DestHeight, int(h),
						   DTA_VirtualWidth, UI_WIDTH,
						   DTA_VirtualHeight, UI_HEIGHT,
						   DTA_LeftOffset, 0,
						   DTA_TopOffset, 0,
						   DTA_Alpha, alpha);
	}

	static ui void ScreenDrawTexture(TextureID tex, double pct_x, double pct_y, double scale = 1.0, double alpha = 1.0, bool centerX = false, bool centerY = false, bool lowerUnpegged = false)
	{
		int x = int(pct_x * UI_WIDTH);
		int y = int(pct_y * UI_HEIGHT);
		// calculate size based on texture's scale
		int tw, th;
		[tw, th] = TexMan.GetSize(tex);
		int w = int(tw * scale);
		int h = int(th * scale);
		if ( centerX ) x -= w / 2;
		if ( centerY ) y -= h / 2;
        if ( lowerUnpegged ) y -= h;

		Screen.DrawTexture(tex, true, x, y, DTA_Alpha, alpha,
						   DTA_DestWidth, w, DTA_DestHeight, h,
						   DTA_VirtualWidth, UI_WIDTH,
						   DTA_VirtualHeight, UI_HEIGHT,
						   // ignore any sprite offsets, this is UI-land
						   DTA_LeftOffset, 0,
						   DTA_TopOffset, 0);
	}

	static ui void ScreenDrawString(String s, Color c, Font f, double pct_x, double pct_y, double lineHeight = DIALOG_VSPACE, double wrapWidth = 1.0, bool dropShadow = true, bool centerX = false, double centerYHeight = -1, double alpha = 1, double displayPercent = 1.0)
	{
		// thanks gwHero https://forum.zdoom.org/viewtopic.php?f=122&t=59381&p=1039574
		int x = int(pct_x * UI_WIDTH);
		int y = int(pct_y * UI_HEIGHT);
		// center vertically within given height
		if ( centerYHeight > 0 )
			y += int((centerYHeight * UI_HEIGHT) / 2 - (lineHeight * UI_HEIGHT) / 2);
		// split strings separated by \n into multiple lines
		Array<String> lines;
		s.Split(lines, "\n");

        int totalCharacterCount = 0;
        Array<String> dLines;
        //Let's work out our total number of lines and characters first
		for ( int i = 0; i < lines.Size(); i++ )
		{
			BrokenLines blines = f.BreakLines(lines[i], int(wrapWidth * UI_WIDTH));
			for ( int n = 0; n < blines.Count(); n++ )
            {
                String plainText = bLines.StringAt(n);
                dLines.push(plainText);
                totalCharacterCount += plainText.Length();
            }
        }

        //Now write each line until we exceed our limit
        int charactersDisplayed = 0;
        int charactersToDisplay = int(totalCharacterCount * displayPercent);
        for (int i = 0; i < dLines.Size(); i++)
		{
            String textToDisplay = dlines[i];
            //If the characters already displayed total above our display target, we can break
            if (charactersDisplayed >= charactersToDisplay) { break; }

            // If the target would be hit by drawing this line, we have to truncate
            if (charactersDisplayed + textToDisplay.Length() > charactersToDisplay) {
                int charactersToDisplayThisLine = (charactersToDisplay - charactersDisplayed);
                textToDisplay = textToDisplay.Left(charactersToDisplaythisLine);
            }
            // center wrapped line horizontally
            int x = int(pct_x * UI_WIDTH);
            if ( centerX )
                x -= f.StringWidth(textToDisplay) / 2;
            if ( dropShadow )
            {
                // line color codes will mess up shadow color, strip em
                String plainText = textToDisplay;
                plainText.Replace("\cg", "\cm");
                plainText.Replace("\ck", "\cm");
                plainText.Replace("\cd", "\cm");
                plainText.Replace("\cv", "\cm");
                plainText.Replace("\cl", "\cm");
                Screen.DrawText(f, Font.CR_BLACK, x + 1, y + 1,
                                plainText,
                                DTA_VirtualWidth, UI_WIDTH,
                                DTA_VirtualHeight, UI_HEIGHT,
                                DTA_Alpha, alpha);
            }
            // void DrawText(Font font, int normalcolor, double x, double y, String text, ...);
            Screen.DrawText(f, c, x, y, textToDisplay,
                            DTA_VirtualWidth, UI_WIDTH,
                            DTA_VirtualHeight, UI_HEIGHT,
                            DTA_Alpha, alpha);
            // between wrap-breaks and \n-breaks, don't carriage return twice
            if ( dLines.Size() > 1 ) { y += int(lineHeight * UI_HEIGHT); }
            charactersDisplayed += textToDisplay.Length();
        }
	}

	static ui Vector2 GetVirtualVector(Vector2 inVector) {
		Vector2 mv = RealToVirtual(inVector);
		mv.x /= UI_WIDTH;
		mv.y /= UI_HEIGHT;
		return mv;
	}

}