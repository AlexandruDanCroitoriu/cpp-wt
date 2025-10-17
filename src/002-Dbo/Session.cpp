#include "002-Dbo/Session.h"
#include "002-Dbo/Tables/Permission.h"
#include "000-Server/Server.h"

#include <Wt/Dbo/backend/Sqlite3.h>
#include <Wt/Auth/Identity.h>
#include <Wt/Auth/PasswordService.h>

using namespace Wt;


Session::Session(const std::string &sqliteDb)
{
  #ifdef DEBUG
    // Debug mode - use SQLite
    auto connection = std::make_unique<Dbo::backend::Sqlite3>(sqliteDb);
    connection->setProperty("show-queries", "true");
    Wt::log("info") << "Using SQLite database in debug mode";
  #else
    // Production mode - use PostgreSQL
    const char *postgres_host = std::getenv("POSTGRES_HOST");
    if (!postgres_host) {
      throw std::runtime_error("POSTGRES_HOST environment variable is not set");
    }

    const char *postgres_port = std::getenv("POSTGRES_PORT");
    if (!postgres_port) {
      throw std::runtime_error("POSTGRES_PORT environment variable is not set");
    }

    const char *postgres_dbname = std::getenv("POSTGRES_DBNAME");
    if (!postgres_dbname) {
      throw std::runtime_error("POSTGRES_DBNAME environment variable is not set");
    }

    const char *postgres_user = std::getenv("POSTGRES_USER");
    if (!postgres_user) {
      throw std::runtime_error("POSTGRES_USER environment variable is not set");
    }

    const char *postgres_password = std::getenv("POSTGRES_PASSWORD");
    if (!postgres_password) {
      throw std::runtime_error("POSTGRES_PASSWORD environment variable is not set");
    }

    std::string postgres_conn_str = "host=" + std::string(postgres_host) + 
                    " port=" + std::string(postgres_port) +
                    " dbname=" + std::string(postgres_dbname) + 
                    " user=" + std::string(postgres_user) + 
                    " password=" + std::string(postgres_password);
    auto connection = std::make_unique<Dbo::backend::Postgres>(postgres_conn_str.c_str());
    Wt::log("info") << "Using PostgreSQL database in production mode";
  #endif
  
  setConnection(std::move(connection));

  mapClass<User>("user");
  mapClass<Permission>("permission");
  mapClass<AuthInfo>("auth_info");
  mapClass<AuthInfo::AuthIdentityType>("auth_identity");
  mapClass<AuthInfo::AuthTokenType>("auth_token");

  try {
    if (!created_) {
      createTables();
      created_ = true;
      Wt::log("info") << "Created database.";
    } else {
      Wt::log("info") << "Using existing database";
    }
  } catch (Wt::Dbo::Exception& e) {
    Wt::log("info") << "Using existing database";
  }
  users_ = std::make_unique<UserDatabase>(*this);
  createInitialData();

}


Auth::AbstractUserDatabase& Session::users()
{
  return *users_;
}

dbo::ptr<User> Session::user() const
{
  if (login_.loggedIn()) {
    dbo::ptr<AuthInfo> authInfo = users_->find(login_.user());
    return authInfo->user();
  } else
    return dbo::ptr<User>();
}

dbo::ptr<User> Session::user(const Wt::Auth::User& authUser)
{
  dbo::ptr<AuthInfo> authInfo = users_->find(authUser);

  dbo::ptr<User> user = authInfo->user();

  if (!user) {
    user = add(std::make_unique<User>());
    authInfo.modify()->setUser(user);
  }

  return user;
}

const Auth::AuthService& Session::auth()
{
  return Server::authService;
}

const Auth::PasswordService& Session::passwordAuth()
{
  return Server::passwordService;
}

std::vector<const Auth::OAuthService *> Session::oAuth()
{
  std::vector<const Wt::Auth::OAuthService *> result;
  result.reserve(Server::oAuthServices.size());
  for (const auto& auth : Server::oAuthServices) {
    result.push_back(auth.get());
  }
  return result;
}

Wt::Dbo::ptr<User> addUser(Wt::Dbo::Session& session, UserDatabase& users, const std::string& loginName,
             const std::string& email, const std::string& password)
{
  Wt::Dbo::Transaction t(session);
  auto user = session.addNew<User>(loginName);
  auto authUser = users.registerNew();
  authUser.addIdentity(Wt::Auth::Identity::LoginName, loginName);
  authUser.setEmail(email);
  Server::passwordService.updatePassword(authUser, password);

  // Link User and auth user
  Wt::Dbo::ptr<AuthInfo> authInfo = session.find<AuthInfo>("where id = ?").bind(authUser.id());
  authInfo.modify()->setUser(user);

  t.commit();
  return user;
}

void Session::createInitialData()
{
  // Create STYLUS permission if it doesn't exist
  {
    Wt::Dbo::Transaction t(*this);
    
    Wt::Dbo::ptr<Permission> stylus_permission = find<Permission>()
      .where("name = ?")
      .bind("STYLUS");
    
    if (!stylus_permission) {
      stylus_permission = add(std::make_unique<Permission>("STYLUS"));
      Wt::log("info") << "Created STYLUS permission.";
    }
    
    t.commit();
  }
  
  // Check if admin user already exists by querying auth_identity table
  {
    Wt::Dbo::Transaction t(*this);
    
    Wt::Dbo::ptr<AuthInfo::AuthIdentityType> existingIdentity = 
      find<AuthInfo::AuthIdentityType>()
      .where("provider = ? AND identity = ?")
      .bind(Wt::Auth::Identity::LoginName)
      .bind("maxuli");
    
    if (existingIdentity) {
      Wt::log("info") << "Admin user 'maxuli' already exists, skipping creation.";
      t.commit();
      return;
    }
    
    t.commit();
  }
  
  // Create admin user using the authentication framework
  Wt::Dbo::ptr<User> adminUser = addUser(*this, *users_, "maxuli", "maxuli@example.com", "asdfghj1");
  
  // Assign STYLUS permission to admin user
  {
    Wt::Dbo::Transaction t(*this);
    
    // Reload the permission within this transaction
    Wt::Dbo::ptr<Permission> stylus_permission = find<Permission>()
      .where("name = ?")
      .bind("STYLUS");
    
    adminUser.modify()->permissions_.insert(stylus_permission);
    t.commit();
  }
  
  Wt::log("info") << "Created admin user 'maxuli' with STYLUS permission.";
}



