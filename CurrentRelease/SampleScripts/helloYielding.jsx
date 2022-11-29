//
// helloYielding.jsx
//
// Run with rre (Run Remote ExtendScript)
//
/****

rre illustrator hello.jsx
rre tgh://freddy/illustrator hello.jsx
rre illustrator hello.jsx
      
*****/

// Allow Tightener to instrument script with TIGHTENER.yield() calls
// Pragma is either 'yield on' or 'yield off'

//@yield on

var feedBack = function(message) {
   alert(message); 
};

feedBack("Hello from helloYielding.jsx");
