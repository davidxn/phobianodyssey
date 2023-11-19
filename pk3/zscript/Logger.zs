class PoLogger : Thinker
{
    static clearscope void Log(String type, String content) {
    	String myType = "";
    	if (type == "walk") { myType = "\cn" .. type; }
    	if (type == "turn") { myType = "\cv" .. type; }
        if (type == "inv") { myType = "\ca" .. type; }
        if (type == "dialog") { myType = "\cb" .. type; }

    	console.printf(myType .. ": \cj" .. content);
    }
}