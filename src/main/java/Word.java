import org.docx4j.openpackaging.exceptions.Docx4JException;
import org.docx4j.openpackaging.packages.WordprocessingMLPackage;
import org.docx4j.wml.ContentAccessor;
import org.docx4j.wml.P;
import org.docx4j.wml.R;
import org.docx4j.wml.Text;

import javax.xml.bind.JAXBElement;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class Word {
    public WordprocessingMLPackage getTemplate(String name) throws Docx4JException, FileNotFoundException {
        WordprocessingMLPackage template = WordprocessingMLPackage.load(new FileInputStream(new File(name)));
        return template;
    }

    public List<Object> getAllElementFromObject(Object obj, Class<?> toSearch) {
        List<Object> result = new ArrayList<Object>();
        if (obj instanceof JAXBElement) obj = ((JAXBElement<?>) obj).getValue();

        if (obj.getClass().equals(toSearch))
            result.add(obj);
        else if (obj instanceof ContentAccessor) {
            List<?> children = ((ContentAccessor) obj).getContent();
            for (Object child : children) {
                result.addAll(getAllElementFromObject(child, toSearch));
            }

        }
        return result;
    }

    public void replacePlaceholder(WordprocessingMLPackage template, String name, String placeholder ) {
        List<Object> texts = getAllElementFromObject(template.getMainDocumentPart(), Text.class);
        for (Object text : texts) {
            Text textElement = (Text) text;
            if (textElement.getValue().equals(placeholder)) {
                textElement.setValue(name);
            }
        }
    }

    public void replaceAllPlaceholder(WordprocessingMLPackage template, HashMap<String, String> mappings ) {
        List<Object> texts = getAllElementFromObject(template.getMainDocumentPart(), Text.class);
        System.out.println("================ Строки в шаблоне ================");
        for (Object text : texts) {
            Text textElement = (Text) text;
            String key = textElement.getValue();
            System.out.println("Key=["+key+"]");
            if (key.length()>3) {
                int startKey = key.indexOf("${", 0);
                key = key.substring(2, key.length() - 1);
                if (mappings.containsKey(key) && startKey==0){
                    textElement.setValue(mappings.get(key));
                }

               //System.out.println("Str=" + key);
            }
        }
    }


    public void writeDocxToStream(WordprocessingMLPackage template, String target) throws IOException, Docx4JException {
        File f = new File(target);
        template.save(f);
    }

    public void replacePlaceholder(WordprocessingMLPackage template, String placeholder, Object insObject ) {
        List<Object> texts = getAllElementFromObject(template.getMainDocumentPart(), Text.class);
        for (Object text : texts) {
            Text textElement = (Text) text;
            if (textElement!=null)
                if (textElement.getValue().equals(placeholder)) {
                    R r = (R)textElement.getParent();
                    P p = (P)r.getParent();
                    p.getContent().add(0, insObject);
                    textElement.setValue("");
                }
        }
    }
}
