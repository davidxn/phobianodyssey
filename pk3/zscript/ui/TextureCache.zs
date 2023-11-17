class TextureCache {

	ui Map<string, TextureID> textureCache;

	ui void Init() {
		textureCache.Insert("invBGFrame", TexMan.CheckForTexture("invbg", 0));
        textureCache.Insert("invBGFrame2", TexMan.CheckForTexture("invbg2", 0));
        textureCache.Insert("invBGFrame3", TexMan.CheckForTexture("invbg3", 0));
        textureCache.Insert("invBGFrame4", TexMan.CheckForTexture("invbg4", 0));
        textureCache.Insert("invBGClosedFrame", TexMan.CheckForTexture("invbgcl", 0));
		textureCache.Insert("invItemBG", TexMan.CheckForTexture("invitmbg", 0));
        textureCache.Insert("itemShopBG", TexMan.CheckForTexture("shopbg", 0));
        textureCache.Insert("armoryBG", TexMan.CheckForTexture("armorybg", 0));
		textureCache.Insert("invHilight", TexMan.CheckForTexture("invsel", 0));
        
        textureCache.Insert("power1", TexMan.CheckForTexture("POPOWER1", 0));

        textureCache.Insert("dialogBackFrame", TexMan.CheckForTexture("DIALBACK", 0));
        textureCache.Insert("dialogOptionFrame", TexMan.CheckForTexture("DIALRESP", 0));
        textureCache.Insert("blockMapFrame", TexMan.CheckForTexture("MAPBLOCK", 0));
        textureCache.Insert("blockMapSquares", TexMan.CheckForTexture("MAPSQUAR", 0));
        textureCache.Insert("mapCounter", TexMan.CheckForTexture("MAPCOUNT", 0));

		textureCache.Insert("mouseMiniCursorTex", TexMan.CheckForTexture("invcurs", 0));
        textureCache.Insert("weaponCursorTex", TexMan.CheckForTexture("guncurs", 0));
	}

	ui TextureID Get(string key) {
		return textureCache.Get(key);
	}
}