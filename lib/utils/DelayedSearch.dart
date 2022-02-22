import 'dart:async';

class DelayedSearch {
  Timer onFinishedTyping;
  final Function executeSearch;
  final Function onComplete;
  final Function onEmptyQuery;
  final int timeoutInMillis;
  bool _isSearching = true;
  Stopwatch stopwatch = new Stopwatch();

  DelayedSearch(this.executeSearch, this.timeoutInMillis, this.onEmptyQuery, this.onComplete);

  Timer _buildOnTypeFinishedCallback(String value) {
    return Timer(Duration(milliseconds: timeoutInMillis), () async {
      if(value == null || value.isEmpty){
        _isSearching = false;
        onEmptyQuery();
        return;
      }
      var result = await executeSearch(value);
      if(_isSearching)
        onComplete(result);
    });
  }

  void cancel() {
    stopwatch.stop();
    stopwatch.reset();
    stopwatch.start();
    onFinishedTyping?.cancel();
  }

  Future<void> doSearchAddress(String value) async {
    if(value != null && value.length > 0 && !_isSearching)
      _isSearching = true;
    if(!stopwatch.isRunning) {
      stopwatch.start();
      return;
    }

    if(value == null || value.isEmpty){
      stopwatch.stop();
      stopwatch.reset();
      stopwatch.start();
      onFinishedTyping?.cancel();
      _isSearching = false;
      onEmptyQuery();
      return;
    }

    if(stopwatch.elapsedMilliseconds<timeoutInMillis){
      stopwatch.stop();
      stopwatch.reset();
      stopwatch.start();
      onFinishedTyping?.cancel();
      onFinishedTyping = _buildOnTypeFinishedCallback(value);
      return;
    }

    stopwatch.stop();
    stopwatch.reset();
    stopwatch.start();

    var result = await executeSearch(value);
    if(_isSearching)
      onComplete(result);

  }

}