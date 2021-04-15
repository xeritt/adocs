import org.docx4j.docProps.variantTypes.Array;
import org.docx4j.docProps.variantTypes.Null;

import java.io.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

public class FileHelper {
    static public HashMap<String, String> loadConfig(String name, HashMap<String, String> mappings){
        if (mappings == null){
            mappings = new HashMap<String, String>();
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(new File(name)))) {
            String line;
            System.out.println("------------ Строки для замены в шаблоне ------------");
            System.out.println("Файл для загрузки ["+name+"]");
            System.out.println("-----------------------------------------------------");
            while ((line = reader.readLine()) != null) {
                System.out.println("["+line+"]");
                String vals[] = line.split("=");
                if (vals.length<2){
                    mappings.put(vals[0], "");
                } else {
                    mappings.put(vals[0], vals[1]);
                }
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return mappings;
    }

    static public List<List<String>> loadChet(String name){
        List<List<String>> list = new ArrayList<>();

        try (BufferedReader reader = new BufferedReader(new FileReader(new File(name)))) {
            String line;
            System.out.println("------------ Фактурная часть ------------");
            System.out.println("Файл для загрузки ["+name+"]");
            System.out.println("-----------------------------------------------------");

            while ((line = reader.readLine()) != null) {
                System.out.println("Line=["+line+"]");
                String vals[] = line.split(";");
                List<String> work = new ArrayList<>();
                work.addAll(Arrays.asList(vals));
                list.add(work);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return list;
    }

    public static void showChet(List<List<String>> chet){
        for (int i = 0; i < chet.size(); i++) {
            List<String> work = chet.get(i);
            //System.out.println("Work "+i);
            for (int j = 0; j < work.size(); j++) {
                System.out.print(work.get(j)+" | ");
            }
            System.out.println();
        }
    }
}
