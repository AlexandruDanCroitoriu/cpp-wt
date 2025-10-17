#include "000_Server/Server.h"
#include "001_App/App.h"
#include <Wt/WLogger.h>

int main(int argc, char **argv)
{
    Wt::log("info") << "Starting Wt server...";

    Server server(argc, argv);

    server.run();

    return 0;
}

// try
//   {

//       Server server(argc, argv);
      
//       server.setServerConfiguration(argc, argv, WTHTTP_CONFIGURATION);
//       server.addEntryPoint(
//           Wt::EntryPointType::Application,
//           [=](const Wt::WEnvironment &env)
//           {
//               return std::make_unique<App>(env);
//           },
//           "/");
//       // Session::configureAuth();

//       server.run();
//   }
//   catch (Wt::WServer::Exception &e)
//   {
//       std::cerr << e.what() << "\n";
//       return 1;
//   }
//   catch (std::exception &e)
//   {
//       std::cerr << "exception: " << e.what() << "\n";
//       return 1;
//   }