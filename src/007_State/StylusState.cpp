#include "007_State/StylusState.h"

StylusState::StylusState()
    : doc_(std::make_shared<tinyxml2::XMLDocument>())
{
    state_file_path_ = "../../static/stylus/stylus-state.xml";

}