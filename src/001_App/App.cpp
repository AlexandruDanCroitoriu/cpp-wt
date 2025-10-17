#include "App.h"
// #include "006-Navigation/Navigation.h"

// #include "002-Theme/DarkModeToggle.h"
// #include "002-Theme/ThemeSwitcher.h"

// #include "003-Components/ComponentsDisplay.h"
// #include "008-AboutMe/AboutMe.h"
// #include "101-StarWarsApi/StarWarsApi.h"

#include <Wt/WStackedWidget.h>
#include <Wt/WPushButton.h>
#include <Wt/WMenu.h>
#include <Wt/WLabel.h>
#include <Wt/WTheme.h>
#include <Wt/WContainerWidget.h>
#include <Wt/WDialog.h>
#include <memory>
#include <Wt/WRandom.h>

// #include "101-Stylus/000-Utils/StylusState.h"

App::App(const Wt::WEnvironment& env)
    : Wt::WApplication(env),
      session_(appRoot() + "../dbo.db")
{
#ifdef DEBUG
    Wt::log("debug") << "App::App() - application starting";
#endif
    // Title
    setTitle("Wt CPP app title");
    // setHtmlClass("dark");
    setCssTheme("polished");
    useStyleSheet(docRoot() + "/static/css/tailwind.minify.css?v=" + Wt::WRandom::generateId()); // Cache busting

    // require("https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4");
    // require("https://unpkg.com/vue@3/dist/vue.global.prod.js");
    // require("https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js");
    
    // root()->addStyleClass("max-w-screen max-h-screen overflow-none font-body bg-surface text-on-surface");
    {
        // Load XML bundles that override the default Wt authentication templates.
        auto& bundle = wApp->messageResourceBundle();
        bundle.use(docRoot() + "/static/0_stylus/xml/001_Auth/ovrwt-auth");
        bundle.use(docRoot() + "/static/0_stylus/xml/001_Auth/ovrwt-auth-login");
        bundle.use(docRoot() + "/static/0_stylus/xml/001_Auth/ovrwt-auth-strings");
        bundle.use(docRoot() + "/static/0_stylus/xml/001_Auth/ovrwt-registration-view");
    }


    authDialog_ = wApp->root()->addNew<Wt::WDialog>("");
    authDialog_->setTitleBarEnabled(false);
    authDialog_->setClosable(false);
    authDialog_->setModal(true);
    authDialog_->escapePressed().connect([this]() {
        if (authDialog_ != nullptr) {
            authDialog_->hide();
        }
    });
    authDialog_->setMinimumSize(Wt::WLength(100, Wt::LengthUnit::ViewportWidth), Wt::WLength(100, Wt::LengthUnit::ViewportHeight));
    authDialog_->setMaximumSize(Wt::WLength(100, Wt::LengthUnit::ViewportWidth), Wt::WLength(100, Wt::LengthUnit::ViewportHeight));
    authDialog_->setStyleClass("absolute top-0 left-0 right-0 bottom-0 w-screen h-screen");
    authDialog_->setMargin(Wt::WLength("-21em"), Wt::Side::Left); // .Wt-form width
    authDialog_->setMargin(Wt::WLength("-200px"), Wt::Side::Top); // ???
    authDialog_->contents()->setStyleClass("min-h-screen min-w-screen m-1 p-1 flex items-center justify-center bg-surface text-on-surface");
    authWidget_ = authDialog_->contents()->addWidget(std::make_unique<AuthWidget>(session_));
    appRoot_ = root()->addNew<Wt::WContainerWidget>();
    
    session_.login().changed().connect(this, &App::authEvent);
    authWidget_->processEnvironment();
    if (!session_.login().loggedIn()) {
        session_.login().changed().emit();
    }

    #ifdef DEBUG
    Wt::log("debug") << "App::App() - Application instantiated";
    #endif

    authWidget_->show();

}

void App::authEvent() {
    if (session_.login().loggedIn()) {
        const Wt::Auth::User& u = session_.login().user();
        #ifdef DEBUG
        log("debug") << "User " << u.id() << " (" << u.identity(Wt::Auth::Identity::LoginName) << ")" << " logged in.";
        #endif
        if (authDialog_->isVisible()) {
            authDialog_->hide();
        }
    } else {
        #ifdef DEBUG
        log("debug") << "User logged out.";
        #endif
        if (!authDialog_->isVisible()) {
            authDialog_->show();
        }
    }
    createApp();
}

void App::createApp()
{
    if (appRoot_ != nullptr && !appRoot_->children().empty()) {
        appRoot_->clear();
    }

    if (session_.login().loggedIn()) {
        Wt::Dbo::Transaction transaction(session_);

        // Query for STYLUS permission, taking first result if multiple exist
        auto stylusPermission = session_.find<Permission>()
            .where("name = ?")
            .bind("STYLUS")
            .resultValue();
        if (stylusPermission && session_.user()->hasPermission(stylusPermission)){
            #ifdef DEBUG
            Wt::log("debug") << "Permission STYLUS found, Stylus will be available.";
            #endif
            // stylus_ = appRoot_->addChild(std::make_unique<Stylus::Stylus>(session_));
        } else {
            #ifdef DEBUG
            Wt::log("debug") << "Permission STYLUS not found, Stylus will not be available.";
            #endif
        }
        transaction.commit();
    }

    // auto theme_switcher = appRoot_->addNew<ThemeSwitcher>(session_);
    // theme_switcher->addStyleClass("fixed bottom-16 right-3");
    // auto dark_mode_toggle = appRoot_->addNew<DarkModeToggle>(session_);
    // dark_mode_toggle->addStyleClass("fixed bottom-3 right-3");

    // auto navbar = appRoot_->addNew<Navigation>(session_);
    
    // navbar->addPage("Portofolio", std::make_unique<AboutMe>());
    // navbar->addPage("Start wars api", std::make_unique<StarWarsApi>());
    // navbar->addPage("UI Penguin", std::make_unique<ComponentsDisplay>());
}
