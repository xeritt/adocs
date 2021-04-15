import org.docx4j.XmlUtils;
import org.docx4j.jaxb.Context;
import org.docx4j.openpackaging.exceptions.Docx4JException;
import org.docx4j.openpackaging.io.SaveToZipFile;
import org.docx4j.openpackaging.packages.WordprocessingMLPackage;
import org.docx4j.openpackaging.parts.WordprocessingML.MainDocumentPart;
import org.docx4j.wml.*;
import org.xml.sax.SAXException;
import javax.xml.bind.JAXBException;
import javax.xml.parsers.ParserConfigurationException;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.StringTokenizer;

public class Main {

    private static String newlineToBreakHack(String r) {

        StringTokenizer st = new StringTokenizer(r, "\n\r\f"); // tokenize on the newline character, the carriage-return character, and the form-feed character
        StringBuilder sb = new StringBuilder();

        boolean firsttoken = true;
        while (st.hasMoreTokens()) {
            String line = (String) st.nextToken();
            if (firsttoken) {
                firsttoken = false;
            } else {
                sb.append("</w:t><w:br/><w:t>");
            }
            sb.append(line);
        }
        return sb.toString();
    }

    public static void main(String[] args) throws Docx4JException, JAXBException, SAXException, IOException, ParserConfigurationException {
//        System.out.println("Hello");
        org.docx4j.wml.ObjectFactory factory = Context.getWmlObjectFactory();
        //String inputfilepath = System.getProperty("user.dir") + "/chet.docx";
        String inputfilepath = args[0];

        boolean save = true;
        //String outputfilepath = System.getProperty("user.dir") + "/OUT_VariableReplace.docx";
        String outputfilepath = args[1];
        WordprocessingMLPackage wordMLPackage = WordprocessingMLPackage.load(new java.io.File(inputfilepath));
        MainDocumentPart documentPart = wordMLPackage.getMainDocumentPart();

        HashMap<String, String> mappings = new HashMap<String, String>();
        String propspath = args[2];//реквизиты
        mappings = FileHelper.loadConfig(propspath, mappings);

        String agentpath = args[3];//реквизиты заказчика
        mappings = FileHelper.loadConfig(agentpath, mappings);

        String docpath = args[4];//путь к документу
        mappings = FileHelper.loadConfig(docpath, mappings);

        String workspath = args[5];//путь к фактурной части
        //mappings = FileHelper.loadConfig(workspath, mappings);

        long start = System.currentTimeMillis();

        Word w = new Word();
        w.replaceAllPlaceholder(wordMLPackage, mappings);
        List<List<String>> chet = FileHelper.loadChet(workspath);
        FileHelper.showChet(chet);
        Tbl tbl = TableHelper.getTable(wordMLPackage, factory, chet, chet.size(), 6);
        w.replacePlaceholder(wordMLPackage, "${ФактурнаяЧасть}", tbl);

        long end = System.currentTimeMillis();
        long total = end - start;
        System.out.println("Time: " + total);
        // Save it
        if (save) {
            SaveToZipFile saver = new SaveToZipFile(wordMLPackage);
            saver.save(outputfilepath);
        } else {
            System.out.println(XmlUtils.marshaltoString(documentPart.getJaxbElement(), true,
                    true));
        }


    }
}
