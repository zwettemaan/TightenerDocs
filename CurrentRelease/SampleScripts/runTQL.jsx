// Mix doScript and evalTQL - they should share a Tightener scope
app.doScript("a = 1", ScriptLanguage.TQL);
alert(app.evalTQL("a"));
