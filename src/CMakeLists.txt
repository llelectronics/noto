set(noto_SRCS
    fileio.h
    main.cpp
    )

qt5_add_resources(RESOURCES resources.qrc)
add_executable(noto ${noto_SRCS} ${RESOURCES})
target_link_libraries(noto Qt5::Core Qt5::Qml Qt5::Quick Qt5::Svg)
install(TARGETS noto ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
