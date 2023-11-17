class PoLogger : Thinker
{
    static void Log(String type, String content) {
    	String myType = "";
    	if (type == "walk") { myType = "\cn" .. type; }
    	if (type == "turn") { myType = "\cv" .. type; }
        if (type == "inv") { myType = "\ca" .. type; }

    	console.printf(myType .. ": \cj" .. content);
    }
}