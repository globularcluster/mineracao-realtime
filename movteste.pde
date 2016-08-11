import processing.video.*;
import http.requests.*;

final String URL = "http://globo-api-stage.twist.systems/data/twitter/wordcloud/bunb/?limit=5000&from_date=1460678400";
final String TOKEN = "token af9780d82ecd2c26e7df8134bcaeb00b4d4753f9";

private GetRequest get;
private Movie myMovie;
private String words;    // texto exibido
private int x;           // movimento do texto exibido

void setup() {
  size(770, 420);

  // configurações do video em background
  myMovie = new Movie(this, "teste.mov");
  myMovie.play();
  myMovie.loop();

  x = width;  // limite direito da janela
  words = new String();

  APIConection();

  // thread que faz a resquisição de novos dados
  thread("getArray");
}

void draw() {

  image(myMovie, 0, 0);

  // efeito de transição do texto
  if (!words.isEmpty()) {
    if (x == words.length()*5)
      x=770;
    else 
    x-=3;
  }

  textSize(50);
  text(words, x, 400);
}

void movieEvent(Movie m) {
  m.read();
}

public void APIConection() {
  get = new GetRequest(URL);
  get.addHeader("Authorization", TOKEN);
}

public void getArray() {
  // faz o GET e aguarda a resposta

  int timer = frameCount;
  get.send();

  // a API retorna um array, é necessário que esse array esteja 
  // associado a uma chave para que o método parseJSONObject() 
  // funcione. Rsolvi o problema com uma concatenação simple.
  String JSONRecebido = get.getContent();
  String JSON = "{ \"dados\": " + JSONRecebido + "}";

  JSONObject response = parseJSONObject(JSON);

  JSONArray terms = response.getJSONArray("dados");

  String newWords = new String();
  for (int i=0; i<terms.size(); i++) {
    JSONObject term = terms.getJSONObject(i);
    newWords += " " + term.getString("term");
  } 

  words = newWords;
  timer -= frameCount;
  println("Palavras atualizadas. (delay: " + timer + ")");
}