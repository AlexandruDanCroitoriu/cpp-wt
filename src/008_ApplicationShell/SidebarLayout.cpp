#include "008_ApplicationShell/SidebarLayout.h"
#include "004_Theme/DarkModeToggle.h"

#include <Wt/WApplication.h>
#include <Wt/WText.h>
#include <Wt/WImage.h>
#include <Wt/WPushButton.h>
#include <Wt/WTemplate.h>

SidebarLayout::SidebarLayout(Session& session)
    : Wt::WTemplate(),
    session_(session)
{
#ifdef DEBUG
    Wt::log("debug") << "SidebarLayout::SidebarLayout() - initializing";
#endif

    setTemplateText(Wt::WString::tr("sidebar-layout-with-header"));

    sidebar_ = this->bindWidget("sidebar", std::make_unique<Wt::WTemplate>(Wt::WString::tr("sidebar-content")));
    sidebar_->addFunction("tr", &Wt::WTemplate::Functions::tr);
    auto dark_mode_toggle = sidebar_->bindWidget("dark-mode-toggle", std::make_unique<DarkModeToggle>(session_));

    sidebar_m_ = this->bindWidget("sidebar-mobile", std::make_unique<Wt::WTemplate>(Wt::WString::tr("sidebar-content")));
    sidebar_m_->addFunction("tr", &Wt::WTemplate::Functions::tr);
    auto dark_mode_toggle_m = sidebar_m_->bindWidget("dark-mode-toggle", std::make_unique<DarkModeToggle>(session_));

    content_stack_ = this->bindWidget("content", std::make_unique<Wt::WStackedWidget>());

    // Content
    auto wrapper = std::make_unique<Wt::WContainerWidget>();
    auto button = wrapper->addNew<Wt::WPushButton>("Test Button");
    addMenuItem("home", std::move(wrapper), "heroicon-home");

}

void SidebarLayout::addMenuItem(std::string name, std::unique_ptr<Wt::WContainerWidget> content, std::string icon_tr_id)
{
    // Desktop menu
    auto menu_item = sidebar_->bindWidget(name, std::make_unique<Wt::WAnchor>(Wt::WLink(Wt::LinkType::InternalPath, "/"+name), name));

    menu_item->insertWidget(0, std::make_unique<Wt::WTemplate>(Wt::WString::tr(icon_tr_id)));
    // Mobile Sidebar menu
    auto menu_item_m = sidebar_m_->bindWidget(name, std::make_unique<Wt::WAnchor>(Wt::WLink(Wt::LinkType::InternalPath, "/"+name), name));
    menu_item_m->insertWidget(0, std::make_unique<Wt::WTemplate>(Wt::WString::tr(icon_tr_id)));

    auto menu_item_content = content_stack_->addWidget(std::move(content));
    
    wApp->internalPathChanged().connect([=](const std::string& path) {
        if (path == "/"+name) {
            content_stack_->setCurrentWidget(menu_item_content);
            for(auto& item : selected_menu_items_) {
                item->toggleStyleClass("!bg-surface-alt", false, false);
                item->toggleStyleClass("!text-primary", false, false);
            }
            selected_menu_items_.clear();
            selected_menu_items_.push_back(menu_item);
            selected_menu_items_.push_back(menu_item_m);
            for(auto& item : selected_menu_items_) {
                item->toggleStyleClass("!bg-surface-alt", true, false);
                item->toggleStyleClass("!text-primary", true, false);
            }
        }
    });
}