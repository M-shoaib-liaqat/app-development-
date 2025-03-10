import 'package:flutter/material.dart';

class GradeBook extends StatefulWidget {
  const GradeBook({super.key});

  @override
  _GradeBookState createState() => _GradeBookState();
}

class _GradeBookState  extends State<GradeBook>{
@override
 Widget build(BuildContext context){
  return Scaffold(
    appBar: AppBar(
      title: const Text('Grade Book'),
      backgroundColor: Colors.deepPurple,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
    ),
    body: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Center(
        child: Text('Wellcome to Grade Book', style: TextStyle(fontSize: 18)),
      ),
      SizedBox(height: 20,),
      Table(
        border: TableBorder.all(),
        columnWidths: const {
          0:FixedColumnWidth(120.0),
          1:FixedColumnWidth(80.0),
          2:FixedColumnWidth(80.0),
          3:FixedColumnWidth(100.0),
    
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: Colors.blue
            ),
            children: const[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Subject',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color:Colors.white),textAlign: TextAlign.center,),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Grade',style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.bold,color:Colors.white),textAlign: TextAlign.center,),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Total marks',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color:Colors.white),textAlign: TextAlign.center,),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Obtained Marks',style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.bold,color:Colors.white),textAlign: TextAlign.center,),
              ),
            ]
          ),
          TableRow(
              children: const[
               Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Math', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('A', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('95', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Excellent', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                  ),
                ],
          ),
          TableRow(
              children: const[
               Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Compiler Construction', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('A', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('95', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Excellent', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                  ),
                ],
          ),
        ],
      )
    ],
    ),

  );
 }
}