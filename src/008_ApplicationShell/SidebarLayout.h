#ifndef SIDEBARLAYOUT_H
#define SIDEBARLAYOUT_H

#include <Wt/WContainerWidget.h>

class SidebarLayout : public Wt::WContainerWidget
{
public:
    SidebarLayout();
    ~SidebarLayout() override = default;

private:
    void setupLayout();
    
    Wt::WContainerWidget* sidebar_;
    Wt::WContainerWidget* mainContent_;
};

#endif // SIDEBARLAYOUT_H
