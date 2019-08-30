import 'package:github_search/models/search_item.dart';
import 'package:github_search/services/github_api.dart';
import 'package:rxdart/rxdart.dart';

class SearchBloc {
  final GithubApi _githubApi;
  Observable<List<SearchItem>> _results;
  final _query = new BehaviorSubject<String>();
  final _page = new BehaviorSubject<int>();

  Sink<String> get queryEvent => _query.sink;
  Sink get pageEvent => _page.sink;
  Observable<List<SearchItem>> get items => _results;

  SearchBloc(this._githubApi) {
    _results = _query
    // pega apenas textos diferentes do anterior digitado pelo usuário
        .distinct()
    // pega apenas textos maiores que 3 caracteres
        .where((e) => e.length >= 3)
    // descarta dados enquanto o usuário não ficar pelo menos 250ms sem digitar algo
    // se o usuário digitar novamente nesse intervalo de tempo, zera o contador
        .debounceTime(Duration(milliseconds: 250))
    // cria uma nova paginação e reseta a mesma toda vez que o usuário pesquisar o novo termo
        .switchMap((term) => _page
        // a paginação começa com o valor 0
            .startWith(0)
        // cada próxima página é mapeada para 1
            .mapTo(1)
        // faz uma acumulação, acumula o valor anterior do Observable
        // com o valor atual, ex: acc= 1, curr=1 => 1+1 = 2
            .scan((acc, curr, i) => acc + curr, 0)
        // faz a requisição chamando a API, passando o termo e a página
            .asyncMap((i) => _githubApi.search(term, i, 10))
        // para de paginar quando encontra uma página vazia (página limite)
            .takeWhile((e) => e.items.isNotEmpty == true)
        // faz uma acumulação dos resultados da paginação, inserindo todos numa lista
            .scan<List<SearchItem>>(
                (acc, curr, i) => acc..addAll(List.from(curr.items)), []));

    _results.listen((e) => print(e.length));
    _page.listen(print);
  }

  void dispose() {
    _query.close();
    _page.close();
  }
}
