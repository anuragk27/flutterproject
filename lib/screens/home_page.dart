import 'package:material_ui/material_ui.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('App Title'),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(child: Text('Menu')),
            // ListTile(
            //   leading: const Icon(Icons.home),
            //   title: const Text('Home'),
            //   onTap: () {},
            // ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // const Divider(height: 1)
              // Card(
              //   child: SizedBox(
              //     width: 300,
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Padding(
              //           padding: const EdgeInsets.all(16.0),
              //           child: ClipRRect(
              //             borderRadius: BorderRadius.circular(6),
              //             child: Image.asset(
              //               'assets/images/india_gate.jpg',
              //               width: 260,
              //               height: 160,
              //               fit: BoxFit.cover,
              //             ),
              //           ),
              //         ),
              //         const Text('I am a Card with an image'),
              //         const SizedBox(height: 12),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 20),
              // SizedBox(
              //   width: 310,
              //   child: Card(
              //     child: ListTile(
              //       title: const Text('One-line ListTile with trailing icon'),
              //       trailing: IconButton(
              //         icon: const Icon(Icons.more_vert),
              //         onPressed: () {},
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
