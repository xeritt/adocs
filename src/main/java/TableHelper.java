import org.docx4j.model.table.TblFactory;
import org.docx4j.openpackaging.packages.WordprocessingMLPackage;
import org.docx4j.wml.*;

import javax.xml.bind.JAXBElement;
import java.math.BigInteger;
import java.util.List;

public class TableHelper {
    public static Tbl getTable(WordprocessingMLPackage wordMLPackage, ObjectFactory factory, List<List<String>> lines, int numrows, int numcols){
        int writableWidthTwips = wordMLPackage.getDocumentModel()
                .getSections().get(0).getPageDimensions().getWritableWidthTwips();
        int columnNumber = numcols;

        Tbl tbl = TblFactory.createTable(1, numcols, writableWidthTwips/columnNumber);
        TblPr tblPr = tbl.getTblPr();
        TblWidth tblWidth = tblPr.getTblW();//factory.createTblWidth();
        tblWidth.setType("pct");
        tblWidth.setW(BigInteger.valueOf(5000));
        tblPr.setTblW(tblWidth);
        tbl.setTblPr(tblPr);

        TblGrid tblGrid = tbl.getTblGrid();
        List<TblGridCol> tblGridCol = tblGrid.getGridCol();
        tblGridCol.get(0).setW(BigInteger.valueOf(419));
        tblGridCol.get(1).setW(BigInteger.valueOf(5449));
        tblGridCol.get(2).setW(BigInteger.valueOf(1047));
        tblGridCol.get(3).setW(BigInteger.valueOf(942));
        tblGridCol.get(4).setW(BigInteger.valueOf(1257));
        tblGridCol.get(5).setW(BigInteger.valueOf(1362));
        tbl.setTblGrid(tblGrid);

        String headers[] = {"№", "Товары (работы, услуги)","Кол-во","Ед.","Цена","Сумма"};
        addHeaders(factory, tbl, headers);
        double sum = 0;
        for (List<String> line : lines) {
            Tr tr = factory.createTr();
            int i = 0;
            JcEnumeration align = JcEnumeration.RIGHT;
            for (String str:line) {
                if (i == 0){
                    align = JcEnumeration.CENTER;
                } else if (i==1){
                    align = JcEnumeration.LEFT;
                } else{
                    align = JcEnumeration.RIGHT;
                }
                TcPr tcPr = createTcPrBorders(factory, 1, STBorder.SINGLE);
                tr.getContent().add(createTc(factory, str, null, tcPr, align));
                if (i==line.size()-1){
                    sum = sum + Double.parseDouble(str);
                }
                i++;

            }
            tbl.getContent().add(tr);
        }

        addItogo(factory, tbl, (int)sum);

        Word w = new Word();
        fwMoney mo = new fwMoney(sum);
        String money_as_string = mo.num2str();
        w.replacePlaceholder(wordMLPackage, money_as_string, "${СуммаДокументаПрописью}");

        return tbl;
    }

    public static void addHeaders(ObjectFactory factory, Tbl tbl, String headers[]){
        List<Object> rows = tbl.getContent();
        Tr tr = (Tr)rows.get(0);//factory.createTr();
        int i = 0;
        for (String header:headers) {
            Tc tc = (Tc)tr.getContent().get(i++);
            P p = createP(factory, header);
            p.setPPr(createPAlign(factory,null, JcEnumeration.CENTER));
            TcPr tcPr = createTcPrBorders(factory, 1, STBorder.SINGLE);
            tc.setTcPr(tcPr);
            tc.getContent().set(0, p);
        }
    }

    public static void addItogo(ObjectFactory factory, Tbl tbl, int sum){
        Tr tr = factory.createTr();
        tr.getContent().add(createTcBoldRight(factory, "Итого к оплате:"));
        tr.getContent().add(createTc(factory, String.valueOf(sum), createRprBold(factory), JcEnumeration.RIGHT, 1));
        tbl.getContent().add(tr);

        Tr tr2 = factory.createTr();
        tr2.getContent().add(createTc(factory, "В том числе НДС:", null, JcEnumeration.RIGHT, 5));
        tr2.getContent().add(createTc(factory, "Без НДС", JcEnumeration.RIGHT));
        tbl.getContent().add(tr2);



    }

    public static PPr createPAlign(ObjectFactory factory, PPr pPr, JcEnumeration align){
        if (pPr==null)
            pPr = factory.createPPr();
        Jc jc = factory.createJc();
        jc.setVal(align);
        pPr.setJc(jc);
        return pPr;
    }

    public static TcPr createGridSpan(ObjectFactory factory, TcPr tcPr, int numspan){
        if (tcPr==null)
            tcPr = factory.createTcPr();
        TcPrInner.GridSpan span = factory.createTcPrInnerGridSpan();
        span.setVal(BigInteger.valueOf(numspan));
        tcPr.setGridSpan(span);
        return tcPr;
    }

    public static RPr createRprBold(ObjectFactory factory){
        RPr rpr = factory.createRPr();
        BooleanDefaultTrue b = new BooleanDefaultTrue();
        rpr.setB(b);
        return rpr;
    }

    public static Tc createTcBoldRight(ObjectFactory factory, String text){
        P p = createP(factory, text, createRprBold(factory));
        p.setPPr(createPAlign(factory,null, JcEnumeration.RIGHT));

        Tc td = factory.createTc();
        td.getContent().add(p);
        td.setTcPr(createGridSpan(factory, null, 5));
        return td;
    }

    public static TcPr createTcPrBorders(ObjectFactory factory, int val, STBorder style){
        TcPr tcPr = factory.createTcPr();
        TcPrInner.TcBorders borders = new TcPrInner.TcBorders();
        CTBorder ctBorder = new CTBorder();
        ctBorder.setSz(BigInteger.valueOf(val));
        ctBorder.setVal(style);

        borders.setBottom(ctBorder);
        borders.setTop(ctBorder);
        borders.setLeft(ctBorder);
        borders.setRight(ctBorder);
        tcPr.setTcBorders(borders);
        return tcPr;
        //td.setTcPr(tcPr);
    }

    public static Tc createTc(ObjectFactory factory, String text, RPr rpr, TcPr tcPr, JcEnumeration align){
        P p = createP(factory, text, rpr);
        p.setPPr(createPAlign(factory,null, align));

        Tc td = factory.createTc();
        td.getContent().add(p);
        td.setTcPr(tcPr);
        return td;
    }

    public static Tc createTc(ObjectFactory factory, String text, RPr rpr, JcEnumeration align, int numspan){
        P p = createP(factory, text, rpr);
        p.setPPr(createPAlign(factory,null, align));

        Tc td = factory.createTc();
        td.getContent().add(p);
        td.setTcPr(createGridSpan(factory, null, numspan));
        return td;
    }

    public static Tc createTc(ObjectFactory factory, String text, JcEnumeration align){
        P p = createP(factory, text);
        p.setPPr(createPAlign(factory,null, align));
        Tc td = factory.createTc();
        td.getContent().add(p);
        return td;
    }

    public static Tc createTc(ObjectFactory factory, String text){
        P p = createP(factory, text);
        Tc td = factory.createTc();
        td.getContent().add(p);
        return td;
    }

    public static P createP(ObjectFactory factory, String text){
        P p = factory.createP();
        R r = factory.createR();
        Text t = factory.createText();
        t.setValue(text);
        r.getContent().add(t);
        p.getContent().add(r);
        return p;
    }

    public static P createP(ObjectFactory factory, String text, RPr rpr){
        P p = factory.createP();
        R r = factory.createR();
        r.setRPr(rpr);
        Text t = factory.createText();
        t.setValue(text);
        r.getContent().add(t);
        p.getContent().add(r);
        return p;
    }


}
