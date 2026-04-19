class CounterController {
  int _counter = 0; 

  int get value => _counter;

  int _step = 1;
  
  final List<String> _history = [];
  List<String> get history => List.unmodifiable(_history);

  void increment(){
    _counter += _step;
    _addHistory("Menambah $_step");
  } 

  void changeStep(int newStep){
    if(newStep > 0){
      _step = newStep;
    }
  }

  void decrement() { 
    if (_counter > 0){
      _counter -= _step;
      _addHistory("Mengurangi $_step");
    }
    if(_counter < 0 ){
      reset();
    }  
  }

  void reset(){
    _counter = 0;
    _addHistory("Reset ke 0");
  }


  void _addHistory(String action) {
    final time =
        "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";

    _history.add("$action pada jam $time");

    if (_history.length > 5) {
      _history.removeAt(0); 
    }
  }
} 