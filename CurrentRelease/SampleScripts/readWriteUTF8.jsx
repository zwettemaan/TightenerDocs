alert(app.readUTF8File("~/.profile"));
app.writeUTF8File("~/Desktop/t.txt", "hello\n");
app.appendUTF8File("~/Desktop/t.txt", "hello again\n");