import org.docx4j.openpackaging.parts.SAXHandler;
import org.xml.sax.SAXException;

import java.util.HashMap;

public class MySAXHandler extends SAXHandler {

    private HashMap<String, String> mappings = new HashMap<String, String>();
    private StringBuilder text = new StringBuilder();

    public MySAXHandler(HashMap<String, String> mappings) throws SAXException {
        super();
        this.mappings = mappings;
    }

    @Override
    public void startDocument() throws SAXException {
        super.startDocument();
        System.out.println("------------->Start");
    }

    @Override
    public void endDocument() throws SAXException {
        super.endDocument();
        System.out.println("------------->End");
        System.out.println(text);
    }

    @Override
    public void characters(char[] ch, int start, int length) throws SAXException {

        StringBuilder sb = new StringBuilder();
        sb.append(ch, start, length);
        //System.out.println("characters=["+sb.toString()+"]");
        text.append(sb);

        String wmlString = replace(sb.toString(), 0, new StringBuilder(), mappings).toString();
//			System.out.println(wmlString);

        char[] charOut = wmlString.toCharArray();

        this.getContentHandler().characters(charOut, 0, charOut.length);

    }

    private StringBuilder replace(String wmlTemplateString, int offset, StringBuilder strB,
                                  java.util.Map<String, ?> mappings) {

        //System.out.println("wmlTemplateString=["+wmlTemplateString+"]");
        try {
            int startKey = wmlTemplateString.indexOf("${", offset);
            if (startKey == -1)
                return strB.append(wmlTemplateString.substring(offset));
            else {
                strB.append(wmlTemplateString.substring(offset, startKey));
                int keyEnd = wmlTemplateString.indexOf('}', startKey);
                String key = wmlTemplateString.substring(startKey + 2, keyEnd);
                Object val = mappings.get(key);
                if (val == null) {
                    System.out.println("Invalid key '" + key + "' or key not mapped to a value");
                    strB.append(key);
                } else {
                    if (wmlTemplateString.equals("${ФактурнаяЧасть}")){
                        strB.append("${ФактурнаяЧасть}");//ничего не делаем
                    } else
                        strB.append(val.toString());
                }
                System.out.println("wmlTemplateString=["+wmlTemplateString+"]");
                return replace(wmlTemplateString, keyEnd+1, strB, mappings);
            }
        } catch (Exception e){
            e.printStackTrace();
        }
        return strB;
    }
}