#include "SidebarLayout.h"
#include <Wt/WContainerWidget.h>
#include <Wt/WTemplate.h>

#include <Wt/WApplication.h>

SidebarLayout::SidebarLayout()
    : Wt::WContainerWidget()
{
#ifdef DEBUG
    Wt::log("debug") << "SidebarLayout::SidebarLayout() - initializing";
#endif

    wApp->messageResourceBundle().use(wApp->docRoot() + "/static/0_stylus/xml/000_General/Application_Shell");
    setupLayout();
}

void SidebarLayout::setupLayout()
{
    // Main container with flex layout
    auto temp = this->addNew<Wt::WTemplate>(Wt::WString::tr("sidebar-layout-with-header"));

#ifdef DEBUG
    Wt::log("debug") << "SidebarLayout::setupLayout() - layout created";
#endif
}
