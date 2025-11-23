#ifndef SIDEBARLAYOUT_H
#define SIDEBARLAYOUT_H

#include <Wt/WTemplate.h>
#include <Wt/WStackedWidget.h>
#include "002_Dbo/Session.h"
#include <Wt/WAnchor.h>

class SidebarLayout : public Wt::WTemplate
{
public:
    SidebarLayout(Session& session);
    
    void addMenuItem(std::string name, std::unique_ptr<Wt::WContainerWidget> content, std::string icon_tr_id = "");
private:
    Wt::WTemplate* sidebar_;
    Wt::WTemplate* sidebar_m_;

    Wt::WStackedWidget* content_stack_;

    Session& session_;
    std::vector<Wt::WAnchor*> selected_menu_items_;
};

#endif // SIDEBARLAYOUT_H
